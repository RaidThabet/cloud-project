
# Internet-facing ALB across both public subnets.
resource "aws_lb" "alb" {
  name               = "${var.project_name}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name    = "${var.project_name}-backend-alb"
    Project = var.project_name
  })
}

# Backend target group on application port with strict health check path.
resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-backend-tg"
  port     = var.backend_app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = var.backend_health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-backend-tg"
    Project = var.project_name
  })
}

# HTTP listener forwarding external traffic to backend target group.
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-alb-http-listener"
    Project = var.project_name
  })
}

# Launch template used by backend ASG instances in private subnets.
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-backend-lt-"
  image_id      = var.ami_id
  instance_type = var.backend_instance_type

  vpc_security_group_ids = [var.backend_sg_id]

  # User data bootstraps backend app and injects database connection env vars.
  user_data = base64encode(<<-EOT
    #!/bin/bash
    # Stop on first error to avoid half-configured hosts.
    set -e
    # GitHub SHA forcing Launch Template update: ${var.github_sha}

    apt-get update -y
    apt-get install -y git curl ca-certificates gnupg

    # Install Node.js 20.x for backend runtime.
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
    apt-get update -y
    apt-get install -y nodejs

    # Deploy application source code.
    cd /opt
    # TODO: Ensure the repository contains a /backend directory with a production start script.
    git clone ${var.github_repo_url} app
    cd /opt/app/backend

    npm ci

    cat > /etc/environment <<'ENVFILE'
    DB_HOST=${var.db_address}
    DB_PORT=${var.db_port}
    DB_NAME=${var.db_name}
    DB_USER=${var.db_username}
    DB_PASSWORD=${var.db_password}
    PORT=${var.backend_app_port}
    ENVFILE

    # Also create app-local env file and export values for this boot session.
    cat > /opt/app/backend/.env <<'ENVFILE'
    DB_HOST=${var.db_address}
    DB_PORT=${var.db_port}
    DB_NAME=${var.db_name}
    DB_USER=${var.db_username}
    DB_PASSWORD=${var.db_password}
    PORT=${var.backend_app_port}
    ENVFILE
    set -a
    . /opt/app/backend/.env
    set +a

    # Start backend with PM2 to keep process alive across reboots.
    npm install -g pm2
    pm2 start npm --name backend -- start --update-env
    pm2 save
    pm2 startup systemd -u root --hp /root
  EOT
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name    = "${var.project_name}-backend"
      Project = var.project_name
    })
  }
}

# Auto Scaling Group across private subnets.
resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-backend-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.tg.arn]
  min_size            = var.backend_asg_min_size
  desired_capacity    = var.backend_asg_desired_size
  max_size            = var.backend_asg_max_size
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Target tracking policy: scale based on average CPU utilization.
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.project_name}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = var.backend_cpu_target_percent
  }
}

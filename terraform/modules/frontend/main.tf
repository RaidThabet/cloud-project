
resource "aws_instance" "frontend" {
  ami                         = var.ami_id
  instance_type               = var.frontend_instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.frontend_sg_id]

  user_data = <<-EOT
    #!/bin/bash
    # Stop on first error to avoid partial frontend deployment.
    set -e

    apt-get update -y
    apt-get install -y nginx git

    cd /opt
    # TODO: Ensure the repository contains a /frontend folder with index.html, style.css, and app.js.
    git clone ${var.github_repo_url} app
    # TODO: If your frontend uses a different API variable, adjust this replacement command.
    sed -i "s|http://<ALB_DNS_PLACEHOLDER>|http://${var.alb_dns_name}|g" app/frontend/app.js || true
    cp -r /opt/app/frontend/* /var/www/html/

    systemctl enable nginx
    systemctl restart nginx
  EOT

  tags = merge(var.tags, {
    Name    = "${var.project_name}-frontend-ec2"
    Project = var.project_name
  })
}

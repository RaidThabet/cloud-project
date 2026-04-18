
# Main application VPC with DNS support enabled for ALB and RDS resolution.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  })
}

# Public subnet in AZ A for internet-facing resources (ALB and frontend EC2).
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[0]
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name    = "${var.project_name}-public-a"
    Project = var.project_name
  })
}

# Public subnet in AZ B for high availability of public resources.
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[1]
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name    = "${var.project_name}-public-b"
    Project = var.project_name
  })
}

# Private subnet in AZ A for backend ASG and RDS.
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[0]
  availability_zone = var.azs[0]

  tags = merge(var.tags, {
    Name    = "${var.project_name}-private-a"
    Project = var.project_name
  })
}

# Private subnet in AZ B for backend ASG and RDS.
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[1]
  availability_zone = var.azs[1]

  tags = merge(var.tags, {
    Name    = "${var.project_name}-private-b"
    Project = var.project_name
  })
}

# Internet Gateway gives public subnets outbound and inbound internet access.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  })
}

# Elastic IP for the NAT Gateway used by private subnets for outbound internet.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name    = "${var.project_name}-nat-eip"
    Project = var.project_name
  })
}

# NAT Gateway in a public subnet to provide egress for private instances.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(var.tags, {
    Name    = "${var.project_name}-nat-gateway"
    Project = var.project_name
  })

  depends_on = [aws_internet_gateway.main]
}

# Public route table routes internet-bound traffic to the IGW.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  })
}

# Associate public subnet A with the public route table.
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Associate public subnet B with the public route table.
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private route table routes internet-bound traffic to the NAT Gateway.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(var.tags, {
    Name    = "${var.project_name}-private-rt"
    Project = var.project_name
  })
}

# Associate private subnet A with the private route table.
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

# Associate private subnet B with the private route table.
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

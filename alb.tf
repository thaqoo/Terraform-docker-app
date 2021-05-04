# ===============================================
# ALB
# ===============================================
# 1. ALB
resource "aws_lb" "web" {
  name                       = "prod-web-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = true

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
  ]

  access_log {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

# 2. Security group
module "http_sg" {
  source      = "./security_group"
  name        = "http_sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "./security_group"
  name        = "https_sg"
  vpc_id      = aws_vpc.main.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source      = "./security_group"
  name        = "http_redirect_sg"
  vpc_id      = aws_vpc.main.id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
}
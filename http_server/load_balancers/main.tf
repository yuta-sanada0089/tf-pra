variable "subnet_public_a_id" {}
variable "subnet_public_c_id" {}
variable "s3_id" {}
variable "http_sg_security_group_id" {}
variable "https_sg_security_group_id" {}
variable "http_redirect_sg_security_group_id" {}

resource "aws_lb" "example" {
  name                       = "example"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = true

  subnets = [
    var.subnet_public_a_id,
    var.subnet_public_c_id
  ]

  access_logs {
    bucket  = var.s3_id
    enabled  = true
  }

  security_groups = [
    var.http_sg_security_group_id,
    var.https_sg_security_group_id,
    var.http_redirect_sg_security_group_id,
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "これは「HTTP]です"
      status_code  = 200
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

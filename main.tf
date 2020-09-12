provider "aws" {
  region = "ap-northeast-1"
}

module "web_server" {
  source        = "./http_server"
  instance_type = "t2.micro"
}

output "public_dns" {
  value = module.web_server.public_dns
}

module "describe_regions_for_ec2" {
  source      = "./iam_role"
  name        = "describe-regions-for-ec2"
  identifier  = "ec2.amazonaws.com"
  policy      = data.aws_iam_policy_document.allow_describe_regions.json
}

module "s3" {
  source      = "./S3"
}

module "network" { 
  source      = "./network"
}

module "http_sg" {
  source      = "./network/security_groups"
  name        = "http-sg"
  vpc_id      = module.network.vpc_id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "./network/security_groups"
  name        = "https-sg"
  vpc_id      = module.network.vpc_id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source      = "./network/security_groups"
  name        = "http-redirect-sg"
  vpc_id      = module.network.vpc_id
  port        = 8080
  cidr_blocks = ["0.0.0.0/0"]
}

 module "load_balancer" {
   source     = "./http_server/load_balancers"
   subnet_public_a_id = module.network.public_0_id
   subnet_public_c_id = module.network.public_1_id
   s3_id = module.s3.bucket_id
   http_sg_security_group_id = module.http_sg.security_group_id
   https_sg_security_group_id = module.https_sg.security_group_id
   http_redirect_sg_security_group_id = module.http_redirect_sg.security_group_id
 }
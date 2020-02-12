# Terraform recipt for create pre-reqs for running kops
resource "aws_route53_zone" "primary" {
  name = var.domain
}

resource "aws_s3_bucket" "kops_state" {
  bucket = "kops-state-${var.cluster_name}"
  acl    = "private"
}
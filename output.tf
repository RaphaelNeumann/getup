output "kops_state_bucket" {
  value       = aws_s3_bucket.kops_state.bucket
}

output "cluster_domain" {
  value       = "${var.cluster_name}.${var.domain}"
}
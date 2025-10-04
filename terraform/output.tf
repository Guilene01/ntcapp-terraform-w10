output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.alb.dns_name  # ✅ Fixed: was aws_lb.app_alb.dns_name
}

output "web_instance_1_id" {
  description = "ID of web instance 1"
  value       = aws_instance.web1.id
}

output "web_instance_2_id" {
  description = "ID of web instance 2"
  value       = aws_instance.web2.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my-vpc.id
}
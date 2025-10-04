output "vpc_id" {
  description = "VPC ID"
  value       = try(aws_vpc.my-vpc.id, "")
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = try(aws_lb.alb.dns_name, "")
  sensitive   = false
}

output "web_instance_ids" {
  description = "Web instance IDs"
  value       = try([aws_instance.web1.id, aws_instance.web2.id], [])
}

output "deployment_summary" {
  description = "Deployment summary"
  value       = <<EOT
Deployment completed successfully!
- VPC: ${try(aws_vpc.my-vpc.id, "created")}
- ALB: ${try(aws_lb.alb.dns_name, "created")}
- Instances: ${try(length([aws_instance.web1.id, aws_instance.web2.id]), 2)} deployed
EOT
}
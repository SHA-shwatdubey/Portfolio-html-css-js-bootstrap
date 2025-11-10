output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.portfolio_eip.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.portfolio_server.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.portfolio_sg.id
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_eip.portfolio_eip.public_ip}"
}

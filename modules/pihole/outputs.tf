#####
# Output
#####

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.pihole.public_ip
}

output "public_dns" {
  description = "Public IP address"
  value       = aws_instance.pihole.public_dns
}

output "pihole_ip" {
  description = "Public IP address of the Pihole"
  value       = module.pihole.public_ip
}

output "pihole_dns" {
  description = "DNS Public IP address of the Pihole"
  value       = module.pihole.public_dns
}

output "pihole_web" {
  value = "http://${module.pihole.public_ip}/admin"
}

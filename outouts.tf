output "webserver_public_ips" {
  description = "A list of public IP addresses for the web servers."
  value       = aws_instance.webserver.*.public_ip
}

output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

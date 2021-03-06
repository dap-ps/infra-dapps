locals {
  public_ips = aws_instance.main[*].public_ip
  hostnames  = aws_instance.main[*].tags.Name
}

output "public_ips" {
  value = local.public_ips
}

output "hostnames" {
  value = local.hostnames
}

output "hosts" {
  value = zipmap(local.hostnames, local.public_ips)
}

output "instances" {
  value = aws_instance.main
}

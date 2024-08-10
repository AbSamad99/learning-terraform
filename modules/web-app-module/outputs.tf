output "instance1_ip_addr" {
  value = aws_instance.instance1.public_ip
}

output "instance2_ip_addr" {
  value = aws_instance.instance2.public_ip
}

output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}

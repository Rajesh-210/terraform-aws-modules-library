output "instance_ids"        { value = aws_instance.main[*].id }
output "private_ips"         { value = aws_instance.main[*].private_ip }
output "public_ips"          { value = aws_instance.main[*].public_ip }
output "instance_arns"       { value = aws_instance.main[*].arn }

output "web_sg_id"      { value = aws_security_group.web.id }
output "app_sg_id"      { value = aws_security_group.app.id }
output "database_sg_id" { value = aws_security_group.database.id }
output "bastion_sg_id"  { value = aws_security_group.bastion.id }

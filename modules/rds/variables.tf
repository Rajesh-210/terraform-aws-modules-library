variable "project_name"         { type = string }
variable "environment"          { type = string }
variable "subnet_ids"           { type = list(string) }
variable "security_group_ids"   { type = list(string) }
variable "engine_version"       { type = string; default = "15.4" }
variable "instance_class"       { type = string; default = "db.t3.micro" }
variable "allocated_storage"    { type = number; default = 20 }
variable "db_name"              { type = string }
variable "db_username"          { type = string }
variable "db_password"          { type = string; sensitive = true }
variable "backup_retention_days"{ type = number; default = 7 }
variable "multi_az"             { type = bool; default = false }
variable "deletion_protection"  { type = bool; default = true }
variable "skip_final_snapshot"  { type = bool; default = false }
variable "tags"                 { type = map(string); default = {} }

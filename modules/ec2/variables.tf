variable "project_name"         { type = string }
variable "environment"          { type = string }
variable "instance_type"        { type = string; default = "t3.micro" }
variable "instance_count"       { type = number; default = 1 }
variable "ami_id"               { type = string; default = "" }
variable "subnet_ids"           { type = list(string) }
variable "security_group_ids"   { type = list(string) }
variable "root_volume_size"     { type = number; default = 20 }
variable "key_name"             { type = string; default = "" }
variable "create_key_pair"      { type = bool; default = false }
variable "public_key"           { type = string; default = "" }
variable "iam_instance_profile" { type = string; default = null }
variable "user_data"            { type = string; default = null }
variable "tags"                 { type = map(string); default = {} }

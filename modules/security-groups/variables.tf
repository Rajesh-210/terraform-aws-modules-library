variable "project_name"     { type = string }
variable "environment"       { type = string }
variable "vpc_id"            { type = string }
variable "app_port"          { type = number; default = 5000 }
variable "db_port"           { type = number; default = 5432 }
variable "allowed_ssh_cidrs" { type = list(string); default = ["0.0.0.0/0"] }
variable "tags"              { type = map(string); default = {} }

variable "project_name"      { type = string }
variable "environment"       { type = string }
variable "create_ec2_role"   { type = bool; default = true }
variable "create_cicd_role"  { type = bool; default = true }
variable "tags"              { type = map(string); default = {} }

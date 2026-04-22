variable "cluster_name"                  { type = string }
variable "cluster_version"               { type = string; default = "1.29" }
variable "environment"                   { type = string }
variable "vpc_id"                        { type = string }
variable "subnet_ids"                    { type = list(string) }
variable "additional_security_group_ids" { type = list(string); default = [] }
variable "endpoint_private_access"       { type = bool; default = true }
variable "endpoint_public_access"        { type = bool; default = true }
variable "node_group_name"               { type = string; default = "default" }
variable "instance_types"               { type = list(string); default = ["t3.medium"] }
variable "node_disk_size"               { type = number; default = 20 }
variable "desired_nodes"                { type = number; default = 2 }
variable "min_nodes"                    { type = number; default = 1 }
variable "max_nodes"                    { type = number; default = 5 }
variable "tags"                         { type = map(string); default = {} }

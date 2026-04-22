variable "project_name"            { type = string }
variable "environment"             { type = string }
variable "bucket_suffix"           { type = string }
variable "enable_versioning"       { type = bool; default = true }
variable "enable_lifecycle"        { type = bool; default = true }
variable "force_destroy"           { type = bool; default = false }
variable "noncurrent_version_days" { type = number; default = 30 }
variable "object_expiry_days"      { type = number; default = 365 }
variable "tags"                    { type = map(string); default = {} }

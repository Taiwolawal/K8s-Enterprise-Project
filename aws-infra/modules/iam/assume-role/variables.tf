variable "eks_admin_role" {
  type = string
}

variable "admin_assume_role_policy" {
  description = "The JSON policy that grants an entity permission to assume the role."
  type        = string
}


variable "eks_admin_policy" {
  description = "The JSON policy that grants an entity permission to assume the role."
  type        = string
}
variable "tags" {
  type    = map(any)
  default = {}
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = 3600
}

variable "create_role" {
  description = "Whether to create a role"
  type        = bool
  default     = false
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = ""
}


variable "eks_developer_role" {
  type = string
}

variable "developer_assume_role_policy" {
  description = "The JSON policy that grants an entity permission to assume the role."
  type        = string
}
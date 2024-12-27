variable "name" {
  type = string
}

variable "create_group" {
  type = bool
}


variable "group_users" {
  type = list(string)
}

# variable "custom_group_policies" {
#   type = string
# }

variable "custom_group_policy_arns" {
  type = list(string)
}
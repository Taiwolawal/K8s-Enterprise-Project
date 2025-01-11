variable "name" {
  type = string
}

variable "attach_aws_lb_controller_policy" {
  type = bool
}

variable "association_defaults" {
  type    = map(any)
  default = {}
}

variable "association" {
  type    = map(any)
  default = {}
}
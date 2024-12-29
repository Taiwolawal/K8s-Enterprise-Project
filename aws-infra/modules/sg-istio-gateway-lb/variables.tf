variable "name" {
  type    = string
}

variable "description" {
  type = string

}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "create" {
  type    = bool
  default = false
}

variable "ingress_with_cidr_blocks" {
  type    = any
  default = []
}

variable "egress_with_cidr_blocks" {
  type    = any
  default = []
}


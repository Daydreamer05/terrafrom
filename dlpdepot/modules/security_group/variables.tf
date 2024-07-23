variable "from_port" {
  type    = string
  default = "5432"
}

variable "to_port" {
  type    = string
  default = "5432"
}

variable "vpc_id" {
  type = string
}

variable "sg_source" {
  type = list(string)
}

variable "name" {
  type = string
}
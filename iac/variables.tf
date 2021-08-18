variable "region" {
  type = string
}

variable "ubuntu_ami" {
  default = "ami-0f7cd40eac2214b37"
}

variable "pathprefix" {
  type = string
}

variable "pathsuffix" {
  type = string
}

variable "instancetype" {
  type    = string
  default = "t2.micro"
}

variable "ingress_list" {
  type        = list(number)
  description = "list of ingress port"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR for the Public Subnet in a AZ"
  default     = "10.0.1.0/24"
}

variable "private_subnet_a_cidr" {
  description = "CIDR for the Private Subnet in a AZ"
  default     = "10.0.4.0/24"
}

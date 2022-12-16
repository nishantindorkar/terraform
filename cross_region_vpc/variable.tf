variable "region" {
  type    = list(string)
  default = ["us-east-1", "ap-south-1"]
}

# variable "region-mumbai" {
#   type    = string
#   default = "ap-south-1"
# }

variable "profile" {
  type    = string
  default = "nishant"
}

variable "cidr_block" {
  type    = list(string)
  default = ["10.0.0.0/16", "192.168.0.0/16"]
}

variable "tags" {
  type    = string
  default = "server"
}

variable "public_cidr_block" {
  type    = list(string)
  default = ["10.0.1.0/24", "192.168.1.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"

}
variable "key_name" {
  type    = list(string)
  default = ["efs-key", "my-all-purpose-key"]
}

variable "ami" {
  type    = list(string)
  default = ["ami-0b0dcb5067f052a63", "ami-074dc0a6f6c764218"]
}

variable "ecs_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}

variable "region" {
  type    = string
  default = "us-east-1"
}
variable "profile" {
  type    = string
  default = "nishant"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "tags" {
  type    = string
  default = "server"
}

variable "public_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_cidr_block" {
  type    = string
  default = "10.0.2.0/24"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"

}
variable "key_name" {
  type    = string
  default = "efs-key"
}

variable "ami" {
  type    = string
  default = "ami-0b0dcb5067f052a63"
}

variable "ecs_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}

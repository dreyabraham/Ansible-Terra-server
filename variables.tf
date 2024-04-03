variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  default     = "eu-west-2a"
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  default     = "ami-0c618421e207909d0"
}

variable "keypair_name" {
  description = "The name of the existing key pair to use for SSH access"
  default     = "my_keyy"
}

variable "private_key_path" {
  description = "The path to the private key file for SSH access"
  default     = "my_keyy.pem"
}
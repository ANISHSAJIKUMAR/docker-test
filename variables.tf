variable "region" {
  type        = string
  default     = "ap-south-1"
}

variable "access_key" {
  type        = string
  default     = ""
}

variable "secret_key" {
  type        = string
  default     = ""
}

variable "ami" {
  type        = string
  default     = "ami-0851b76e8b1bce90b"
}


variable "vpc_id" {
  type        = string
  default     = "vpc-8853b9e3"
}


variable "instance_type_Dockerdb" {
  type        = string
  default     = "t2.micro"
}



variable "enviroument" {
  type        = string
  default     = "anitest"
}


variable "subnet1" {
  type        = string
  default     = "subnet-3063237c"
}

variable "subnet2" {
  type        = string
  default     = "subnet-fdeaf995"
}

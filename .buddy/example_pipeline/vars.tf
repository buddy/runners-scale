variable "AWS_REGION" {
  type = string
}

variable "AWS_AZ" {
  type = string
}

variable "WORKERS" {
  type = number
}

variable "INSTANCE_AMI_ID" {
  type = string
}

variable "INSTANCE_TYPE" {
  type = string
}

variable "INSTANCE_VOLUME_SIZE" {
  type = number
}

variable "INSTANCE_VOLUME_THROUGHPUT" {
  type = number
}

variable "INSTANCE_VOLUME_IOPS" {
  type = number
}

variable "INSTANCE_PUBLIC_KEY" {
  type = string
}

variable "BACKEND_BUCKET" {
  type = string
}

variable "BACKEND_KEY" {
  type = string
}

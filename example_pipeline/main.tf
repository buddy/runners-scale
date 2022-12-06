terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.AWS_REGION
}

resource "aws_key_pair" "worker" {
  key_name   = "worker-key"
  public_key = var.INSTANCE_PUBLIC_KEY
}

resource "aws_security_group" "worker" {
  name        = "worker"
  description = "security group for workers"
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    description = "local network"
    cidr_blocks = [
      "172.31.0.0/16"
    ]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "worker" {
  count                  = var.WORKERS
  ami                    = var.INSTANCE_AMI_ID
  instance_type          = var.INSTANCE_TYPE
  key_name               = aws_key_pair.worker.key_name
  availability_zone      = var.AWS_AZ
  vpc_security_group_ids = [aws_security_group.worker.id]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("/buddy/key.pem")
    port        = 22
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo buddy --yes uninstall --wait"
    ]
  }

  provisioner "remote-exec" {
    script = "/buddy/install.sh"
  }

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = var.INSTANCE_VOLUME_SIZE
    throughput            = var.INSTANCE_VOLUME_THROUGHPUT
    iops                  = var.INSTANCE_VOLUME_IOPS
  }

  tags = {
    Name = "Worker"
  }
}
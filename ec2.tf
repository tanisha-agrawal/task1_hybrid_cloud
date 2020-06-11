provider "aws" {
  region     = "ap-south-1"
  profile    = "tanishaprofile"
}

resource "aws_key_pair" "task1-hybrid-key" {
  key_name   = "task1-hybrid-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "aws_security_group" "task1-sg" {
  name        = "task1-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-2a8b9642"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task1-sg"
  }
}

resource "aws_ebs_volume" "task1-ebs" {
  availability_zone = "ap-south-1a"
  size              = 1

  tags = {
    Name = "task1-ebs"
  }
}

resource "aws_volume_attachment" "task1-ebs-att" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.task1-ebs.id}"
  instance_id = "${aws_instance.task1-ins.id}"
}

resource "aws_instance" "task1-ins" {
  ami               = "ami-0447a12f28fddb066"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "task1-hybrid-key"
  security_groups   = [ "task1-sg" ]
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd -y
                sudo systemctl enable httpd
                sudo yum install git -y 
                mkfs -t ext4  /dev/xvdf1
                mount /dev/xvdf1 /var/www/html
                cd /var/www/html
                git clone https://github.com/tanisha-agrawal/task1_hybrid_cloud.git
EOF
  tags = {
    Name = "task1-ins"
  }
}

variable "awsprops" {
  type = map(string)
  default = {
    region = "us-east-2"
    vpc = "vpc-021512eb050765101"
    ami = "ami-0568773882d492fc8"
    itype = "t2.micro"
    subnet = "subnet-0d8d063ef8ece5a9f"
    publicip = true
    keyname = "mykeypair"
    secgroupname = "photoapp"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet")
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    # iops = 150
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="photoapp"
    Environment = "learning"
    OS = "Amazon Linux"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sg ]

  user_data = "${file("photoapp.sh")}"

}

output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}

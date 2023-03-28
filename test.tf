terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56.0"
    }
  }
}

provider "aws" {

  region  = "us-east-1"
}






## Create a VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
}

## Create a Subnet
resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"
}

# internet gateway
resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id
}

# Route Table
resource "aws_route_table" "tf-r" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }
}
# Create a security group
resource "aws_security_group" "tf-sg" {
  name_prefix = "tf-sg"
  vpc_id      = aws_vpc.tf-vpc.id
  
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# rt associtation
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

# Key pair
resource "aws_key_pair" "tf-key" {
  key_name   = "deployer-key"
  public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyPxzLa5vI1yYHEBXxyXjWQUweGEEFhDkKHCgutbfwNTJQ5xy8//+dAJg0jVynJBvFnfKWKRGjH3e8/bNHQ/6DJwosinkJlVq+MNUOIlNdyMuLyCZqGteo1lgKlUBaMdqojg7Xbre952azHLo/Bpozbye3M9NxMCyhRAdtGC0R+GIom5/H6k9UmFit83ljPM0F2EX6jB23y4fVQ01+Ohv8C+DLgAwECxxH2IDGgy15t/w6D0fxnkJUmaVLNpjWeV+DulX+1RTnKVStPAbXEQxiaXanQblMZ1SuKG8CmU3Pj0poizsHAFZBe61NeSoI5nBkTp4GaVLmLAb7euKj/pmT d00230302@desdemona"
}
#Create instance

resource "aws_instance" "dev" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.tf-subnet.id
  key_name      = "deployer-key"
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_instance" "test" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.tf-subnet.id
  key_name      = "deployer-key"
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_instance" "prod" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.tf-subnet.id
  key_name      = "deployer-key"
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_vol.id
  instance_id = aws_instance.dev.id
}

resource "aws_ebs_volume" "ebs_vol" {
  size              = 1
  availability_zone = "us-east-1b"
}







# Output public IP addresses of instances
output "dev_public_ip" {
  value = aws_instance.dev.public_ip
}

output "test_public_ip" {
  value = aws_instance.test.public_ip
}


output "prod_public_ip" {
  value = aws_instance.test.public_ip
}

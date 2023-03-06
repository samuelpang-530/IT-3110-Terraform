terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
  aws_access_key_id=ASIAQHLQOFBRH2ZIUPEU
aws_secret_access_key=hyRlK6IMr3FyI5gTWIaLNS9hHlGEO2zQjQvnuzV0
aws_session_token=FwoGZXIvYXdzEGgaDHFBQctSt9NLPTlB3iLJAf83V4SLbOSY85eOuBXSpcCOoiTc1rC+Vx8MMvBzKY5ok2mmnXhl7LZN1R+k7nwH+walaMVQy4hP1FVMV+wcnthJY8Jou2s9BcPN8Giq8KxWGyRgcDM7w4nPIgDYKdbtZlxevPaJ+v4Y/8lTyaTyeFNcRAVQM5G4TnNY0yAMUcT1Ergo7l0g8facmSwkt1uvjbWmNCr5/0jphSsn73dT3AlrdIW2LOqtq5eAASmZtafvnzc5kVrWQKqpBnD9A4+8y1jMVfMaA9t+HCieoJagBjIt7FhbDB3ifHRuIOIbbZEZt9s2e/us0sVli36HwAf+RIDbuO/o2rc3ITfm9Zxb
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
  public_key  = file("~/.ssh/id_rsa.pub")
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









# Output public IP addresses of instances
output "dev_public_ip" {
  value = aws_instance.dev.public_ip
}

output "test_public_ip" {
  value = aws_instance.test.public_ip
}

output "prod_public_ip" {
  value = aws_instance.prod.public_ip
}





# main.tf

provider "aws" {
  region = "eu-central-1"  # Choose your desired region
}

resource "aws_instance" "evm_nodes" {
  count         = 3
  ami           = "ami-0766f68f0b06ab145"
  instance_type = "t2.micro"
  key_name      = "ec2-key-pair"

  # Associate the security group with the EC2 instances
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name     = "evm-node-${count.index}"
    Hostname = "evm-node-${count.index}"
  }
}

output "ec2_instance_ips" {
  value = [for instance in aws_instance.evm_nodes : instance.public_ip]
}


# Ensure your security group allows incoming SSH traffic (port 22).
resource "aws_security_group" "ssh_access" {
  name_prefix = "ssh-access-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

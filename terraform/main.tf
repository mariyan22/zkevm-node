provider "aws" {
  region = "eu-central-1"  # Choose your desired region
}

# Define the IAM role for your EC2 instances
resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"  # Name of the IAM role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"  # Example policy ARN
  role       = aws_iam_role.ec2-role
}

# Create EC2 instances and associate IAM roles
resource "aws_instance" "evm_nodes" {
  count         = 3
  ami           = "ami-0766f68f0b06ab145"
  instance_type = "t2.micro"
  key_name      = "ec2-key-pair"

  # Associate the security group with the EC2 instances
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  # Assign IAM role to each instance
  iam_instance_profile = aws_iam_role.ec2-role

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

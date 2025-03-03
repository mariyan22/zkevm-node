# main.tf

provider "aws" {
  region = "eu-central-1"  # Choose your desired region
}

resource "aws_instance" "evm_nodes" {
  count         = 3
  ami           = "ami-0766f68f0b06ab145" 
  instance_type = "t2.micro"
  tags = {
    Name = "evm-node-${count.index}"
  }
}


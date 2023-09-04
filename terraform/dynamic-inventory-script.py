#!/usr/bin/env python

import subprocess
import json

# Run Terraform to get the EC2 instances' output
terraform_cmd = ['terraform', 'output', '-json']
output = subprocess.check_output(terraform_cmd).decode('utf-8')

# Parse Terraform output
terraform_output = json.loads(output)

# Create a list of EC2 instance IDs
instance_ids = terraform_output['ec2_instance_ids']['value']

# Initialize a dictionary to store the public IP addresses
public_ip_addresses = {}

# Use the AWS CLI to fetch the public IP addresses of the EC2 instances
for instance_id in instance_ids:
    aws_cli_cmd = ['aws', 'ec2', 'describe-instances', '--instance-ids', instance_id, '--query', 'Reservations[0].Instances[0].PublicIpAddress', '--output', 'text']
    public_ip = subprocess.check_output(aws_cli_cmd).decode('utf-8').strip()
    public_ip_addresses[instance_id] = public_ip

# Generate the dynamic inventory in JSON format
inventory = {
    'evm_nodes': {
        'hosts': {
            f"evm-node-{count}": {
                'ansible_host': public_ip_addresses[instance_id]
            } for count, instance_id in enumerate(instance_ids)
        },
        'vars': {}
    },
}

print(json.dumps(inventory))

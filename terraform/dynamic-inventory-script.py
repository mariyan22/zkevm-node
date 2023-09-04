#!/usr/bin/env python

import subprocess
import json

# Run Terraform to get the EC2 instances' output
terraform_cmd = ['terraform', 'output', '-json']
output = subprocess.check_output(terraform_cmd).decode('utf-8')

# Parse Terraform output
terraform_output = json.loads(output)

# Create a list of IP addresses
ip_addresses = terraform_output['ec2_instance_ips']['value']

# Generate the dynamic inventory in JSON format
inventory = {
    'evm_nodes': {
        'hosts': {
            f"evm-node-{count}": {
                'ansible_host': ip_addresses[count]
            } for count in range(len(ip_addresses))
        },
        'vars': {}
    },
}

print(json.dumps(inventory))

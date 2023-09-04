#!/usr/bin/env python

import subprocess
import json

# Run Terraform to get the EC2 instances' output
terraform_cmd = ['terraform', 'output', '-json']
output = subprocess.check_output(terraform_cmd).decode('utf-8')

# Parse Terraform output
terraform_output = json.loads(output)

# Generate the dynamic inventory in JSON format
inventory = {
    'evm_nodes': {
        'hosts': {
            f"evm-node-{count}": {} for count, _ in enumerate(terraform_output['ec2_instance_ips']['value'])
        },
        'vars': {}
    },
}

print(json.dumps(inventory))

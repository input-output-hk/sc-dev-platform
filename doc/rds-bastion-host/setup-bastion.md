# CREATE BASTION HOST

Create a Bastion/Jump Host for the Marlowe Runtime RDS instance by running `terragrunt plan` then `terragrunt apply` in each directory below (in the exact order shown):
- Security Group:  infra/us-east-1/prod/rds/bastion/security-group
- Keypair: infra/us-east-1/prod/rds/bastion/key-pair
- EC2 instance: infra/us-east-1/prod/rds/bastion/ec2-instance

P.S: Be sure to update the name and other identifiers if creating a new host

Get the SSH key from the key-pair directory by running:

```terragrunt output -json | jq -r 'select(.private_key_openssh) |.private_key_openssh.value' > bastion-key.pem```

Remember to encode the OpenSSH private key using sops by running the command below:

```sops --kms arn:aws:kms:us-east-1:677160962006:key/fa4d1d08-ad00-4014-97d2-5ff14e00e1b1 --encrypt bastion-key.pem > bastion-key.enc.yaml```

Commit this encrypted key.

Follow the instructions in `use-bastion.md` to use the new bastion. 


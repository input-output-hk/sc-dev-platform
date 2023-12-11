# TO ACCESS BASTION HOST

Decode the file from `setup-bastion.md` using sops command below:

sops --kms arn:aws:kms:us-east-1:677160962006:key/fa4d1d08-ad00-4014-97d2-5ff14e00e1b1 --decrypt bastion-key.enc.yaml > bastion-key.pem

Edit the bastion-key.pem to remove any extraneous characters, so it has the format:

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1******************************************
*****************************************************
*****************************************************
*****************************************************
*****************************************************
*****************************************************
.
.
.
..........................................nMNAAAAAAEC
-----END OPENSSH PRIVATE KEY-----
```

Run the ssh command below to connect to the host: 

```ssh -i bastion-key.pem ec2-user@[BASTION-HOST-IP].compute-1.amazonaws.com```


# AWS - Terraform Boilerplate (Network)

This terraform config is creating from scratch all resources required to deploy a clean production ready environment on your AWS account. 

## Including : 

- VPC
- Elastic IP
- Internet Gateway
- NAT Gateway
- 3 Private Subnets
- 1 Private Route Table & Associations to the 3 Subnets
- 3 Public Subnets
- 1 Public Route Table & Associations to the 3 Subnets

## Run

If you don't have any state, run from scratch
```bash
terraform init
```

Then, copy paste the sample and edit it
```bash
cp terraform.tfvars.sample terraform.tfvars
```

Verify the config
```bash
terraform plan
```

Run it !
```bash
terraform apply
```

Copyleft - Licence WTFPL 🤘
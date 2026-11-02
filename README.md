# Terraform EC2 Instance Template

A reusable Terraform template that builds **dev**, **staging** and **prod** environments on AWS from a single module. Each environment gets an EC2 instance, a DynamoDB table and an S3 bucket, with names and tags generated from one `custom_env` variable.

I built this as a hands-on project to learn Infrastructure as Code, modules, variables and tagging.

## What it creates

Each environment gets its own copy of:

| Resource | Details |
|---|---|
| EC2 instance(s) | Number set by `custom_ec2_count`, 10 GB `gp3` root volume |
| Key pair | Created from a public key file (`terra-automate-key.pub`) |
| Security group | In the default VPC. Inbound: HTTP (80) and SSH (22). Outbound: all traffic |
| DynamoDB table | On-demand billing (`PAY_PER_REQUEST`), partition key `UserID` (string) |
| S3 bucket | Named per environment |

## How it works

The root `main.tf` calls the same module (`./custom_infra`) three times. Only the inputs change:

| Environment | `custom_env` | Instance type |
|---|---|---|
| Dev | `dev` | `t3.micro` |
| Staging | `staging` | `t3.small` |
| Prod | `prod` | `t3.medium` |

```hcl
module "dev-infra" {
  source                   = "./custom_infra"
  custom_env               = "dev"
  custom_ec2_count         = 1
  custom_ec2_ami           = "ami-038a727c6c8b5450a"
  custom_ec2_instance_type = "t3.micro"
}
```

Every resource name is built from `var.custom_env`, so the environments never collide. For example: `dev-app-dynamo-table-...`, `staging-app-bucket-...`, `prodapp-ec2-server-0`.

## Project structure

```
.
├── main.tf                  # Calls the module for dev, staging and prod
├── custom_infra/
│   ├── custom_ec2.tf        # Key pair, security group, rules, EC2 instances
│   ├── custom_s3.tf         # S3 bucket
│   ├── custom_dynamodb.tf   # DynamoDB table
│   ├── custom_outputs.tf    # Output values (public IPs)
│   ├── variables.tf         # Module input variables
│   └── terra-automate-key.pub   # Public key (you generate this)
└── README.md
```

Adjust the file list if your layout differs.

## Tags

All resources are tagged so they are easy to find, filter and track costs for:

| Tag | Value | Example |
|---|---|---|
| `Name` | Environment-based name | `prodapp-ec2-server-0` |
| `Environment` | `var.custom_env` | `prod` |

In the EC2 console you can filter by `Environment = dev` to see only dev servers. The same tags work in Cost Explorer for per-environment cost tracking.

> Tag keys are case-sensitive in AWS. Use `Environment` consistently on every resource.

## Input variables

| Variable | Description | Example |
|---|---|---|
| `custom_env` | Environment name, used in resource names and tags | `dev` |
| `custom_ec2_count` | Number of EC2 instances to create | `1` |
| `custom_ec2_ami` | AMI ID (AMIs are region-specific) | `ami-038a727c6c8b5450a` |
| `custom_ec2_instance_type` | EC2 instance type | `t3.micro` |

## Outputs

| Output | Description |
|---|---|
| `ec2_instance_public_ips` | Public IPs of all EC2 instances in the environment |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.x
- An AWS account and the [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure`)
- An SSH key pair

## Usage

1. **Clone the repo**

   ```bash
   git clone https://github.com/ayush0701/Terraform-ec2-instance-template.git
   cd Terraform-ec2-instance-template
   ```

2. **Generate an SSH key pair** and put the public key in the module folder

   ```bash
   ssh-keygen -t ed25519 -f terra-automate-key
   mv terra-automate-key.pub custom_infra/
   ```

   Keep the private key (`terra-automate-key`) out of the repo.

3. **Check the values** in `main.tf`: the AMI must exist in your region, and S3 bucket names must be globally unique, so change the `-test-ayu` suffix to your own.

4. **Initialize, plan, apply**

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Connect to an instance**

   ```bash
   ssh -i terra-automate-key ec2-user@<public-ip>
   ```

   The username depends on the AMI (`ec2-user`, `ubuntu`, and so on).

6. **Clean up** to avoid charges

   ```bash
   terraform destroy
   ```

   S3 buckets must be empty before they can be destroyed.

## Things to know

- **vCPU limits:** new AWS accounts often have a low vCPU quota (for example 8). Three environments plus other running instances can hit `VcpuLimitExceeded`. Use smaller instance types or request a quota increase in Service Quotas.
- **S3 naming:** bucket names must be lowercase, 3 to 63 characters, with no underscores, and unique across all of AWS.
- **Existing resources:** if a resource already exists in AWS (`ResourceInUseException`, `InvalidGroup.Duplicate`, `BucketAlreadyOwnedByYou`), either import it with `terraform import` or change its name.
- **Plan before apply:** always read `terraform plan`. A `-/+` means the resource will be destroyed and recreated.

## Security notes

- SSH (port 22) is open to `0.0.0.0/0` for learning purposes. For anything real, restrict it to your own IP.
- Never commit private keys (`*.pem`, private key files), `*.tfstate` files or `*.tfvars` files that hold secrets. Public keys (`*.pub`) are safe to commit.
- Recommended `.gitignore`:

  ```gitignore
  .terraform/
  *.tfstate
  *.tfstate.*
  crash.log
  *.tfvars
  *.pem
  *.key
  id_rsa
  terra-automate-key
  ```

## What I learned

- Writing a module once and reusing it with different inputs
- Building resource names and tags from variables
- Using `count` and splat expressions (`[*]`) for multiple instances and outputs
- Importing existing resources with `terraform import`
- Debugging real AWS errors: naming rules, duplicate resources and service quotas
- Keeping secrets and state files out of Git

## Possible next steps

- Store state remotely in S3 with DynamoDB locking
- Restrict SSH to a specific IP range
- Add a custom VPC with public and private subnets
- Run `terraform plan` automatically on pull requests with CI/CD
- Split the three environments into separate state files or workspaces

## Author

**Ayush** — [GitHub](https://github.com/ayush0701)

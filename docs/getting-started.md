# Getting started

[Back to README](../README.md)

## 1. Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.x
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2
- An AWS account and an IAM user with permission to create the resources in this project
- For the `ec2/` stack: an SSH key pair (`ssh-keygen -t ed25519`)

## 2. Clone the repository

```bash
git clone https://github.com/lubjr/learn-terraform-with-aws.git
cd learn-terraform-with-aws
```

## 3. Configure your AWS credentials

Terraform uses the same credentials as the AWS CLI. Pick **one** of the options below.

**Option A: `aws configure` (recommended)**

```bash
aws configure
# AWS Access Key ID:     <your access key>
# AWS Secret Access Key: <your secret key>
# Default region name:   us-east-1
# Default output format: json
```

If you use more than one profile, select it before running Terraform:

```bash
export AWS_PROFILE=my-profile
```

**Option B: environment variables**

```bash
export AWS_ACCESS_KEY_ID="<your access key>"
export AWS_SECRET_ACCESS_KEY="<your secret key>"
export AWS_REGION="us-east-1"
```

Check that your credentials work:

```bash
aws sts get-caller-identity
```

> Never put credentials in `.tf` files or commit them. The `.gitignore` already ignores `*.tfvars` and `*.tfstate` files.

## 4. Adjust the variables (optional)

Every variable has a default value, but you can override any of them by creating a `terraform.tfvars` file inside the stack folder:

```hcl
# ec2/terraform.tfvars
ssh_allowed_cidrs = ["203.0.113.10/32"] # your public IP (see https://checkip.amazonaws.com)
```

Every stack accepts `aws_region` (default `us-east-1`). The variables specific to each stack are listed on its page:

- [EC2 stack](stacks/ec2.md#variables)
- [S3 stack](stacks/s3.md#variables)
- [Lambda stack](stacks/lambda.md#variables)
- [DynamoDB stack](stacks/dynamodb.md#variables)
- [SNS + SQS stack](stacks/sns-sqs.md#variables)

## 5. Deploy a stack

Go into the service folder and run:

```bash
cd s3            # or ec2, lambda, dynamodb, sns-sqs
terraform init   # downloads the providers (first time only)
terraform plan   # shows what will be created
terraform apply  # creates the resources (confirm with "yes")
```

Each stack page has a **Testing** section showing how to check that the deployed service works.

## 6. Clean up

When you are done, run `terraform destroy` in the same folder. See [Costs and cleanup](costs-and-cleanup.md).

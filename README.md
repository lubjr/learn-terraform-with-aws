# learn-terraform-with-aws

A study project for Infrastructure as Code (IaC) with [Terraform](https://developer.hashicorp.com/terraform) on AWS.

Each service lives in its own **independent stack**: a folder with its own configuration and its own state. This way you can deploy, test and destroy one service at a time without touching the others.

## Services

| | Service | Stack | What gets created |
|:-:|---|---|---|
| <img src="docs/icons/ec2.svg" width="40" alt="Amazon EC2"> | Amazon EC2 | [`ec2/`](docs/stacks/ec2.md) | `t3.micro` instance (Ubuntu) reachable over SSH |
| <img src="docs/icons/vpc.svg" width="40" alt="Amazon VPC"> | Amazon VPC | [`ec2/`](docs/stacks/ec2.md) | VPC, public subnet, Internet Gateway, route table and security group |
| <img src="docs/icons/s3.svg" width="40" alt="Amazon S3"> | Amazon S3 | [`s3/`](docs/stacks/s3.md) | Private bucket with all public access blocked |
| <img src="docs/icons/lambda.svg" width="40" alt="AWS Lambda"> | AWS Lambda | [`lambda/`](docs/stacks/lambda.md) | Node.js functions: `hello` (on demand) and `heartbeat` (scheduled) |
| <img src="docs/icons/iam.svg" width="40" alt="AWS IAM"> | AWS IAM | [`lambda/`](docs/stacks/lambda.md) | Lambda execution role and scheduler role |
| <img src="docs/icons/cloudwatch.svg" width="40" alt="Amazon CloudWatch"> | Amazon CloudWatch | [`lambda/`](docs/stacks/lambda.md) | One log group per function with 14-day retention |
| <img src="docs/icons/eventbridge.svg" width="40" alt="Amazon EventBridge"> | Amazon EventBridge Scheduler | [`lambda/`](docs/stacks/lambda.md) | Runs `heartbeat` every 5 minutes |
| <img src="docs/icons/dynamodb.svg" width="40" alt="Amazon DynamoDB"> | Amazon DynamoDB | [`dynamodb/`](docs/stacks/dynamodb.md) | On-demand table with `pk`/`sk` keys and TTL |

## Diagram

```mermaid
flowchart LR
    user([You])

    subgraph ec2stack["Stack ec2/"]
        direction TB
        igw[Internet Gateway]
        subgraph vpc["VPC 10.0.0.0/16"]
            subgraph subnet["Public subnet 10.0.1.0/24"]
                sg{{Security Group<br/>port 22}}
                ec2[EC2 t3.micro<br/>Ubuntu]
            end
        end
        igw --> sg --> ec2
    end

    subgraph s3stack["Stack s3/"]
        bucket[(Private<br/>S3 bucket)]
    end

    subgraph lambdastack["Stack lambda/"]
        direction TB
        hello[Lambda hello<br/>Node.js]
        heartbeat[Lambda heartbeat<br/>Node.js]
        scheduler[EventBridge Scheduler<br/>every 5 min]
        role[IAM Role]
        logs[CloudWatch Logs]
        role -. assumed by .-> hello
        role -. assumed by .-> heartbeat
        scheduler --> heartbeat
        hello --> logs
        heartbeat --> logs
    end

    subgraph dynamodbstack["Stack dynamodb/"]
        table[(DynamoDB table<br/>on-demand)]
    end

    user -- SSH --> igw
    user -- AWS CLI / Console --> bucket
    user -- aws lambda invoke --> hello
    user -- AWS CLI --> table
```

## Quick start

With [Terraform](https://developer.hashicorp.com/terraform/install) and the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and your AWS credentials configured:

```bash
git clone https://github.com/lubjr/learn-terraform-with-aws.git
cd learn-terraform-with-aws/s3   # or ec2, lambda, dynamodb
terraform init
terraform apply
terraform destroy                # when you are done
```

See [Getting started](docs/getting-started.md) for the full setup.

## Documentation

| Page | Contents |
|---|---|
| [Getting started](docs/getting-started.md) | Prerequisites, AWS credentials, variables and deploy workflow |
| [Project structure](docs/project-structure.md) | Folder layout and the file convention shared by every stack |
| [EC2 stack](docs/stacks/ec2.md) | VPC networking and an SSH-reachable instance |
| [S3 stack](docs/stacks/s3.md) | Private S3 bucket |
| [Lambda stack](docs/stacks/lambda.md) | Node.js functions with IAM roles, CloudWatch logs and a schedule |
| [DynamoDB stack](docs/stacks/dynamodb.md) | On-demand table with composite key and TTL |
| [Costs and cleanup](docs/costs-and-cleanup.md) | Free Tier notes, destroying resources and local state caveats |

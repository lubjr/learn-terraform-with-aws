# Project structure

[Back to README](../README.md)

```
.
├── ec2/                  # networking (VPC, subnet, IGW, SG) + EC2 instance
│   ├── network.tf
│   ├── security.tf
│   ├── compute.tf
│   └── ...
├── s3/                   # private S3 bucket
│   └── main.tf
├── lambda/               # Lambda function + IAM + CloudWatch
│   ├── src/index.mjs
│   ├── iam.tf
│   └── main.tf
└── docs/
    ├── icons/            # official AWS Architecture Icons
    ├── stacks/           # one page per stack
    └── *.md              # general guides
```

## Independent stacks

Each top-level folder (`ec2/`, `s3/`, `lambda/`) is a separate Terraform root module. It has its own providers, variables, outputs and state file, and it does not reference resources from the other stacks. You run `terraform init` and `terraform apply` inside the folder you want to deploy.

## File convention

Every stack follows the same file layout:

| File | Contents |
|---|---|
| `terraform.tf` | Required providers and their versions |
| `providers.tf` | AWS provider configuration (region) |
| `variables.tf` | Input variables, all with default values |
| `outputs.tf` | Values printed after `apply` |
| `.terraform.lock.hcl` | Pinned provider versions (committed) |
| other `.tf` files | Resources, split by concern (`network.tf`, `iam.tf`, `main.tf`, ...) |

## Adding a new stack

1. Create a new folder at the root and follow the file convention above.
2. Run `terraform init` and commit the generated `.terraform.lock.hcl`.
3. Add a page in `docs/stacks/` based on the existing ones.
4. Add the service to the table and the diagram in the [README](../README.md), and link the new page.

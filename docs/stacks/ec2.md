# EC2 stack

[Back to README](../../README.md)

<img src="../icons/ec2.svg" width="48" alt="Amazon EC2"> <img src="../icons/vpc.svg" width="48" alt="Amazon VPC">

Source: [`ec2/`](../../ec2)

Creates a minimal public network and a single EC2 instance you can reach over SSH.

## Resources

| File | Resource | Description |
|---|---|---|
| `network.tf` | `aws_vpc.main` | VPC (`10.0.0.0/16`) |
| `network.tf` | `aws_subnet.public` | Public subnet (`10.0.1.0/24`) that assigns public IPs on launch |
| `network.tf` | `aws_internet_gateway.main` | Internet access for the VPC |
| `network.tf` | `aws_route_table.public` | Routes `0.0.0.0/0` to the Internet Gateway |
| `network.tf` | `aws_route_table_association.public` | Attaches the route table to the subnet |
| `security.tf` | `aws_security_group.ssh` | Allows inbound TCP 22 from `ssh_allowed_cidrs` and all outbound traffic |
| `compute.tf` | `aws_key_pair.main` | Uploads your local SSH public key |
| `compute.tf` | `aws_instance.main` | Ubuntu 26.04 instance in the public subnet |

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | Region where resources are created |
| `availability_zone` | `us-east-1a` | Availability zone for the public subnet |
| `vpc_cidr` | `10.0.0.0/16` | CIDR block for the VPC |
| `public_subnet_cidr` | `10.0.1.0/24` | CIDR block for the public subnet |
| `ssh_allowed_cidrs` | `["0.0.0.0/0"]` | IPs allowed to connect over SSH |
| `ami_id` | `ami-0b6d9d3d33ba97d99` | Ubuntu 26.04, **only valid in `us-east-1`** |
| `instance_type` | `t3.micro` | Instance type |
| `key_name` | `my-key` | Name of the key pair in AWS |
| `public_key_path` | `~/.ssh/id_ed25519.pub` | SSH public key uploaded to AWS |

If you change `aws_region`, also change `ami_id` and `availability_zone`, since an AMI ID is only valid in its own region.

By default SSH is open to any IP. For anything beyond a quick test, restrict it to your own IP:

```hcl
# ec2/terraform.tfvars
ssh_allowed_cidrs = ["203.0.113.10/32"] # your public IP (see https://checkip.amazonaws.com)
```

## Outputs

| Output | Description |
|---|---|
| `public_ip` | Public IP address of the instance |

## Testing

Connect over SSH using the IP from the output:

```bash
cd ec2
ssh -i ~/.ssh/id_ed25519 ubuntu@$(terraform output -raw public_ip)
```

## Notes

- The security group (`my-sg`) and key pair (`my-key`) have fixed names, so deploying this stack twice in the same account and region will fail with a name conflict.
- The instance is the resource in this project most likely to incur charges if left running. See [Costs and cleanup](../costs-and-cleanup.md).

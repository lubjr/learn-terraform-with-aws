# DynamoDB stack

[Back to README](../../README.md)

<img src="../icons/dynamodb.svg" width="48" alt="Amazon DynamoDB">

Source: [`dynamodb/`](../../dynamodb)

Creates an on-demand DynamoDB table with a composite primary key and TTL enabled.

## Resources

| File | Resource | Description |
|---|---|---|
| `main.tf` | `aws_dynamodb_table.main` | Table keyed by `pk` (partition) and `sk` (sort), both strings |

The table uses on-demand capacity (`PAY_PER_REQUEST`), so there is no provisioned throughput to size and you pay only for the requests you make. Items are encrypted at rest with an AWS owned key by default.

## Key design

| Attribute | Role | Type |
|---|---|---|
| `pk` | Partition key | String |
| `sk` | Sort key | String |
| `expires_at` | TTL attribute | Number (Unix epoch seconds) |

The generic `pk`/`sk` names let you store different kinds of items in the same table (for example `pk = "USER#1"`, `sk = "PROFILE"`). Only key attributes are declared in Terraform; any other attribute can be added freely per item.

Items with an `expires_at` value in the past are deleted automatically by DynamoDB, usually within a few days of expiring.

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | Region where resources are created |
| `table_name` | `learn-terraform-items` | Name of the table |
| `ttl_attribute` | `expires_at` | Attribute holding the expiration time of an item |
| `point_in_time_recovery` | `false` | Enables continuous backups (billed per GB-month) |

## Outputs

| Output | Description |
|---|---|
| `table_name` | Name of the table |
| `table_arn` | ARN of the table |

## Testing

Write an item, read it back and list the table contents:

```bash
cd dynamodb
TABLE=$(terraform output -raw table_name)

aws dynamodb put-item --table-name "$TABLE" \
  --item '{"pk":{"S":"USER#1"},"sk":{"S":"PROFILE"},"name":{"S":"Terraform"}}'

aws dynamodb get-item --table-name "$TABLE" \
  --key '{"pk":{"S":"USER#1"},"sk":{"S":"PROFILE"}}'

aws dynamodb scan --table-name "$TABLE"
```

Write an item that expires in one hour:

```bash
aws dynamodb put-item --table-name "$TABLE" \
  --item "{\"pk\":{\"S\":\"SESSION#1\"},\"sk\":{\"S\":\"DATA\"},\"expires_at\":{\"N\":\"$(( $(date +%s) + 3600 ))\"}}"
```

## Notes

- The table name is fixed, so deploying this stack twice in the same account and region will fail with a name conflict.
- Unlike S3, `terraform destroy` deletes the table even if it contains items. Their data is lost.

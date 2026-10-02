# Costs and cleanup

[Back to README](../README.md)

## Costs

The resources were chosen to stay within or close to the [Free Tier](https://aws.amazon.com/free/), but that depends on your account. The EC2 instance is the resource most likely to incur charges if left running. **Always run `terraform destroy` when you are done.**

The DynamoDB table uses on-demand capacity, so it costs nothing while idle beyond storage. Point-in-time recovery is disabled by default because its backups are billed separately.

The SNS topic and SQS queues cost nothing while idle. The Free Tier covers 1 million SNS publishes and 1 million SQS requests a month.

The HTTP API is billed per request and costs nothing while idle. It is public, so destroy it when you are done; its throttling settings keep an unexpected burst of traffic from running up the bill.

## Destroying a stack

Run it inside the stack folder:

```bash
cd ec2           # or s3, lambda, dynamodb, sns-sqs, api
terraform destroy
```

If the S3 bucket contains files, `destroy` will fail. Empty the bucket first:

```bash
cd s3
aws s3 rm s3://$(terraform output -raw bucket_name) --recursive
terraform destroy
```

## Local state

Terraform state is stored **locally** (`terraform.tfstate` in each stack folder) and is ignored by git. If you delete that file, Terraform loses track of the resources it created and they must be removed manually from the AWS console. Run `terraform destroy` before deleting the folder or the clone.

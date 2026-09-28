# Lambda stack

[Back to README](../../README.md)

<img src="../icons/lambda.svg" width="48" alt="AWS Lambda"> <img src="../icons/iam.svg" width="48" alt="AWS IAM"> <img src="../icons/cloudwatch.svg" width="48" alt="Amazon CloudWatch">

Source: [`lambda/`](../../lambda)

Deploys a Node.js Lambda function with its execution role and a CloudWatch log group.

## Resources

| File | Resource | Description |
|---|---|---|
| `main.tf` | `data.archive_file.function` | Zips `src/` into `build/function.zip` |
| `main.tf` | `aws_lambda_function.main` | The function (`index.handler`) |
| `main.tf` | `aws_cloudwatch_log_group.function` | `/aws/lambda/<function_name>` with limited retention |
| `iam.tf` | `aws_iam_role.lambda` | Role assumed by the Lambda service |
| `iam.tf` | `aws_iam_role_policy_attachment.basic_execution` | Attaches `AWSLambdaBasicExecutionRole` (write logs only) |

The log group is managed by Terraform so that it gets a retention period and is removed on `destroy`. Otherwise Lambda would create it on first run, with no expiration.

## Function code

[`lambda/src/index.mjs`](../../lambda/src/index.mjs) reads an optional `name` from the event and returns a greeting:

```jsonc
// input
{ "name": "Terraform" }

// output
{ "statusCode": 200, "body": "{\"message\":\"Hello, Terraform!\"}" }
```

Any change inside `src/` changes the zip hash, so the next `terraform apply` redeploys the function.

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | Region where resources are created |
| `function_name` | `learn-terraform-hello` | Function name (also used for the role and log group) |
| `runtime` | `nodejs24.x` | Function runtime |
| `log_retention_days` | `14` | Days to keep the function logs |

## Outputs

| Output | Description |
|---|---|
| `function_name` | Name of the function |
| `function_arn` | ARN of the function |

## Testing

Invoke the function and print the response:

```bash
cd lambda
aws lambda invoke \
  --function-name $(terraform output -raw function_name) \
  --cli-binary-format raw-in-base64-out \
  --payload '{"name":"Terraform"}' \
  out.json && cat out.json
```

View the logs:

```bash
aws logs tail /aws/lambda/$(terraform output -raw function_name) --follow
```

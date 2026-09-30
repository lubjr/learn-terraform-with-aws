# Lambda stack

[Back to README](../../README.md)

<img src="../icons/lambda.svg" width="48" alt="AWS Lambda"> <img src="../icons/iam.svg" width="48" alt="AWS IAM"> <img src="../icons/cloudwatch.svg" width="48" alt="Amazon CloudWatch">

Source: [`lambda/`](../../lambda)

Deploys Node.js Lambda functions, each with its own CloudWatch log group, a shared execution role, and an EventBridge Scheduler schedule for the ones that run on a timer.

## Functions

Every folder under `src/` is one function, declared in the `functions` variable. The stack uses `for_each` over that map, so each entry gets its own zip, function and log group.

| Function | Source | Trigger | Description |
|---|---|---|---|
| `hello` | [`src/hello/index.mjs`](../../lambda/src/hello/index.mjs) | Manual (`aws lambda invoke`) | Returns a greeting for the given name |
| `heartbeat` | [`src/heartbeat/index.mjs`](../../lambda/src/heartbeat/index.mjs) | EventBridge Scheduler, `rate(5 minutes)` | Logs a heartbeat with the current time |

To add a function, create `src/<name>/index.mjs` exporting `handler` and add a `<name>` entry to `functions`. Set `schedule` to have it run on a timer.

## Resources

| File | Resource | Description |
|---|---|---|
| `main.tf` | `data.archive_file.function[*]` | Zips `src/<name>/` into `build/<name>.zip` |
| `main.tf` | `aws_lambda_function.main[*]` | One function per entry, named `<name_prefix>-<name>` |
| `main.tf` | `aws_cloudwatch_log_group.function[*]` | `/aws/lambda/<name_prefix>-<name>` with limited retention |
| `schedule.tf` | `aws_scheduler_schedule.function[*]` | Schedule for each function that sets `schedule` |
| `iam.tf` | `aws_iam_role.lambda` | Role assumed by the Lambda service, shared by all functions |
| `iam.tf` | `aws_iam_role_policy_attachment.basic_execution` | Attaches `AWSLambdaBasicExecutionRole` (write logs only) |
| `iam.tf` | `aws_iam_role.scheduler` | Role assumed by EventBridge Scheduler |
| `iam.tf` | `aws_iam_role_policy.scheduler_invoke` | Allows `lambda:InvokeFunction` on the scheduled functions only |

The log groups are managed by Terraform so that they get a retention period and are removed on `destroy`. Otherwise Lambda would create them on first run, with no expiration.

EventBridge Scheduler does not use a Lambda resource policy. It calls the function with the scheduler role, so that role's policy is what grants the permission.

`main.tf` also has `moved` blocks. They tell Terraform that the old single `hello` function is now `aws_lambda_function.main["hello"]`, so an existing deployment is updated in place instead of destroyed and recreated.

## Function code

`hello` reads an optional `name` from the event and returns a greeting:

```jsonc
// input
{ "name": "Terraform" }

// output
{ "statusCode": 200, "body": "{\"message\":\"Hello, Terraform!\"}" }
```

`heartbeat` writes a JSON line to its log and returns the same data. The schedule sends `{"source":"scheduler"}`. A manual invoke without a payload reports `manual`:

```jsonc
// output
{ "statusCode": 200, "body": "{\"message\":\"Heartbeat\",\"source\":\"scheduler\",\"time\":\"2026-09-30T12:00:00.000Z\"}" }
```

Any change inside a function's folder changes only that function's zip hash, so the next `terraform apply` redeploys only that function.

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | Region where resources are created |
| `name_prefix` | `learn-terraform` | Prefix for function names, log groups and roles |
| `functions` | `hello`, `heartbeat` | Map of functions to deploy, with `description` and optional `schedule` |
| `runtime` | `nodejs24.x` | Runtime for all functions |
| `log_retention_days` | `14` | Days to keep the function logs |

## Outputs

| Output | Description |
|---|---|
| `function_names` | Name of each function, keyed by function |
| `function_arns` | ARN of each function, keyed by function |
| `schedules` | Schedule expression of each scheduled function |

## Testing

List the deployed functions:

```bash
cd lambda
terraform output function_names
```

Invoke `hello` and print the response:

```bash
aws lambda invoke \
  --function-name learn-terraform-hello \
  --cli-binary-format raw-in-base64-out \
  --payload '{"name":"Terraform"}' \
  out.json && cat out.json
```

Wait a few minutes after `apply` and check that `heartbeat` is running on schedule:

```bash
aws logs tail /aws/lambda/learn-terraform-heartbeat --since 15m
```

Follow the logs of any function:

```bash
aws logs tail /aws/lambda/learn-terraform-hello --follow
```

## Costs

`heartbeat` runs about 8,640 times a month. That is well within the Lambda Free Tier (1 million requests a month) and the EventBridge Scheduler free tier (14 million invocations a month). To stop it without destroying the stack, remove its `schedule` or run `terraform destroy`.

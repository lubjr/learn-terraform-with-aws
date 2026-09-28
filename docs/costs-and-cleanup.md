# Costs and cleanup

[Back to README](../README.md)

## Costs

The resources were chosen to stay within or close to the [Free Tier](https://aws.amazon.com/free/), but that depends on your account. The EC2 instance is the resource most likely to incur charges if left running. **Always run `terraform destroy` when you are done.**

## Destroying a stack

Run it inside the stack folder:

```bash
cd ec2           # or s3, or lambda
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



## Pre-Requisites
1. Terraform
2. Azure CLI
3. Helm
4. Kubectl

> :warning: The Terraform state file will be local. Don't commit it to source control.

## Getting Started 

1. Clone this repo
2. Ensure you're logged into Azure with the CLI. `az login`
3. `terraform init`
4. `terraform plan`
5. `terraform apply -auto-approve`
6. Grab some coffee :coffee:
7. Once finished, copy and save the public ip (`terraform output -json | jq '.public_ips.value' -r`)
8. Delete the `cluster.yaml` (It's just an example of how I was using it)
9. Run `rke config`
10. Follow the walk through
- 
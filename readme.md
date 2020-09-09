

## Pre-Requisites
1. Terraform
2. Azure CLI
3. Helm
4. Kubectl

> :warning: The Terraform state file will be local. Don't commit it to source control.

## Creating the RKE cluster

1. Clone this repo
2. Ensure you're logged into Azure with the CLI. `az login`
3. `terraform init`
4. `terraform plan`
5. `terraform apply -auto-approve`
6. Grab some coffee :coffee:
7. Once finished, copy and save the public ip and private ip
    - `terraform output -json | jq '.public_ips.value' -r`
    - `terraform output -json | jq '.private_ips.value' -r`
8. Delete the `cluster.yaml` (It's just an example of how I was using it)
9. Run `rke config`. It will help you create your own `cluster.yaml`
10. Follow the walk through:
- Number of Hosts: 1
- SSH Address: [Insert IP from above :point_up:]
- SSH User: **adminuser**
- Network Plugin: **calico**
- Internal IP of Host: [Insert private IP from above :point_up:]
- Cluster CIDR: **10.0.0.0/16** (Matches the address change for the vnet)
- Control Plane/Worker/etcd host: **Yes**
11. `rke up`
12. Grab some decaf coffee :coffee: You've already had some.
13. After RKE is installed, you should have a kube config file on your directory. `kube_config_cluster.yml`
14. Use it: `export KUBECONFIG=kube_config_cluster.yml`
15. Check you can talk to the cluster, `kubectl get nodes`

## Installing Rancher Server
Now that you have an RKE cluster, install Rancher server.

Follow the steps as described here. For your certificate option, use "Rancher Generated Certs", unless you want to through the trouble of setting up your own DNS. At which point, you can use "Let's Encrypt".

https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/helm-rancher/

## First-Time Set-Up

1. Go to your Rancher server from your browser. 
2. It will ask you to change the admin's password.
  - Username: `admin`
  - Current Password: `admin`
  - New Password: [pick something]


You're in! :tada:


## Tearing everything down

1. `terraform destroy`
2. Delete `kube_config_cluster.yaml`
3. Delete `cluster.yml`
4. Delete `clsuter.rkestate`
5. Go to sleep


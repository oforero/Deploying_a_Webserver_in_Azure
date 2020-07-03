# Deploying a Webserver in Azure

## Create the VM image

* Get your credentials and set them in ARM_environment variables
* go to the image folder: `cd images/folder`
* create the image `packer build server.json`

## Deploy the Infrastructure

* Get your credentials and set them in TF_VAR_ environment variables
* go to the infra folder: `cd terraform/environments/test`
* create the infrastructure: `terraform apply` 
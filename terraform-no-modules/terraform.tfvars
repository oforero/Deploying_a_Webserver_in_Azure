# Azure subscription vars
#client_id       = ""
#client_secret   = ""
#subscription_id = ""
#tenant_id       = ""

# Resource Group/Location
location         = "East US"
resource_group   = "udacity-webserver-project"
application_name = "udacity-webserver"
number_of_vms    = 3


# Network
virtual_network_name = "network"
address_space        = ["10.5.0.0/16"]
address_prefix       = "10.5.1.0/24"

# VM Image
packer_image_group = "udacity-devops"
packer_image       = "my-web-server"


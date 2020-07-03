# Resource Group
variable resource_group {}
variable location {}

# Network
variable virtual_network_name {}
variable address_space {}
variable address_prefix {}
variable nsg_id {}

# Naming
variable resource_name {}
variable resource_suffix {
    type = string
    default = "NET"
}

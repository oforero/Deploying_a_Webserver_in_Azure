# Resource Group/Location
variable location {}
variable resource_group {}

# Naming
variable resource_name {}
variable resource_suffix {
    type = string
    default = "WEBSERVER"
}
variable use_load_balancer {
    type = bool
    default = false
}
variable load_balancer_pool_id {
    default = {}
}

# Parameters
variable number_of_vms {}
variable vm_subnet_id {}

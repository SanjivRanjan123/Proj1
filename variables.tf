#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Linux VM - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

# Service Principal Variables

variable "client_id" {
    description =   "Client ID (APP ID) of the application"
    type        =   string
    default     =   "086f9f46-944c-46c0-93db-2241b73047f7"
}

variable "client_secret" {
    description =   "Client Secret (Password) of the application"
    type        =   string
    default     =   "YU8As1~o4JPwceH_0NwsM94UL.Z.o3cxgO"
}

variable "subscription_id" {
    description =  "Subscription ID"
    type        =   string
    default     =   "8de087f2-1ef1-48c0-abf2-1f7395dd4523"
}

variable "tenant_id" {
    description =   "Tenant ID"
    type        =   string
    default     =   "052c7909-2d11-43ce-a9e6-c9343d28fbd4"
}

# Prefix and Tags

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
    default     =   "Proj1"
}

variable "tags" {
    description =   "Resouce tags"
    type        =   map(string)
    default     =   {
        "project"       =   "Proj1"
        "deployed_with" =   "Terraform1"
    }
}

# Resource Group

variable "location" {
    description =   "Location of the resource group"
    type        =   string
    default     =   "East US"
}

# Vnet and Subnet

variable "vnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.0.0.0/16"
}

variable "subnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.0.1.0/24"
}

# Public IP and NIC Allocation Method

variable "allocation_method" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   list(string)
    default     =   ["Static", "Dynamic"]
}


# VM 

variable "virtual_machine_size" {
    description =   "Size of the VM"
    type        =   string
    default     =   "Standard_D2s_v3"
}

variable "node_count" {
    description =   "Count of Linux VMs"
    type        =   number
    default     =   2
}

variable "computer_name" {
    description =   "Computer name"
    type        =   string
    default     =   "Linuxvm"
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
    default     =   "vmadmin"
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
    default     =   "VMVMAdmin123#"
}

variable "os_disk_caching" {
    default     =       "ReadWrite"
}

variable "os_disk_storage_account_type" {
    default     =       "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
    default     =       64
}

variable "publisher" {
    default     =       "Canonical"
}

variable "offer" {
    default     =       "UbuntuServer"
}

variable "sku" {
    default     =       "18.04-LTS"
}

variable "vm_image_version" {
    default     =       "latest"
}

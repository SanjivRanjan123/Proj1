#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Create a Linux VMs
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

#
# - Provider Block
#

provider "azurerm" {
    
    client_id       =   var.client_id
    client_secret   =   var.client_secret
    subscription_id =   var.subscription_id
    tenant_id       =   var.tenant_id

    features {}
}

#
# - Create a Resource Group
#

resource "azurerm_resource_group" "rg" {
    name                  =   "${var.prefix}-rg"
    location              =   var.location
    tags                  =   var.tags
}

#
# - Create a Virtual Network
#

resource "azurerm_virtual_network" "vnet" {
    name                  =   "${var.prefix}-vnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    location              =   azurerm_resource_group.rg.location
    address_space         =   [var.vnet_address_range]
    tags                  =   var.tags
}

#
# - Create a Subnet inside the virtual network
#

resource "azurerm_subnet" "web" {
    name                  =   "${var.prefix}-web-subnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    virtual_network_name  =   azurerm_virtual_network.vnet.name
    address_prefixes      =   [var.subnet_address_range]
}

#
# - Create a Network Security Group
#

resource "azurerm_network_security_group" "nsg" {
    name                        =       "${var.prefix}-web-nsg"
    resource_group_name         =       azurerm_resource_group.rg.name
    location                    =       azurerm_resource_group.rg.location
    tags                        =       var.tags

    security_rule {
    name                        =       "Allow_SSH"
    priority                    =       100
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "Tcp"
    source_port_range           =       "*"
    destination_port_range      =       "*"
    source_address_prefix       =       "*"
    destination_address_prefix  =       "*"
    
    }
}


#
# - Public IP (To Login to Linux VM)
#

resource "azurerm_public_ip" "pip" {
	count = var.node_count
    name                            =    "${var.prefix}-linuxvm-${format("%02d", count.index+1)}-PublicIP"
    resource_group_name             =     azurerm_resource_group.rg.name
    location                        =     azurerm_resource_group.rg.location
    allocation_method               =     var.allocation_method[0]
    tags                            =     var.tags
}

#
# - Create a Network Interface Card for Virtual Machine
#

resource "azurerm_network_interface" "nic" {
	count = var.node_count
    name                              =   "${var.prefix}-linuxvm-${format("%02d", count.index+1)}-nic"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    tags                              =   var.tags
    ip_configuration                  {
        name                          =  "${var.prefix}-nic-ipconfig"
        subnet_id                     =   azurerm_subnet.web.id
        public_ip_address_id          =   element(azurerm_public_ip.pip.*.id,count.index)
        private_ip_address_allocation =   var.allocation_method[1]
    }
}


#
# - NIC-NSG Association
#

resource "azurerm_network_interface_security_group_association" "nic-nsg" {
	count = var.node_count		
    network_interface_id         =       element(azurerm_network_interface.nic.*.id, count.index)
    network_security_group_id    =       azurerm_network_security_group.nsg.id
}


#
# - Create a Linux Virtual Machines
# 

resource "azurerm_linux_virtual_machine" "vm" {
	count = var.node_count
    name                              =   "${var.prefix}-linuxvm-${format("%02d", count.index+1)}"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    network_interface_ids             =   [element(azurerm_network_interface.nic.*.id,count.index)]
    size                              =   var.virtual_machine_size
    admin_username                    =   var.admin_username
    admin_password                    =   var.admin_password
    disable_password_authentication   =   false

    os_disk  {
        caching                       =   var.os_disk_caching
        storage_account_type          =   var.os_disk_storage_account_type
        #disk_size_gb                  =   var.os_disk_size_gb
    }

    source_image_reference {
        publisher                     =   var.publisher
        offer                         =   var.offer
        sku                           =   var.sku
        version                       =   var.vm_image_version
    }

    tags                              =   var.tags

    #Use Terraform Provisioner to install JDK and Jenkins in VM1. This will  serve as Master node

	provisioner "remote-exec" {
		connection {
		type 		= "ssh"
		user 		= var.admin_username
		password 	= var.admin_password
		host 		= azurerm_public_ip.pip[0].ip_address
	    }
    inline = [
		"export PATH=$PATH:/usr/bin",
		# install java 8
		"sudo apt-get update",
		"sudo apt-get -y install openjdk-8-jdk openjdk-8-jre",
		"export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64",
		"sudo apt-get update",
		"echo $JAVA_HOME",
        "sudo apt-get update",
		"sudo wget https://get.jenkins.io/war-stable/2.289.2/jenkins.war",
		]
        on_failure = continue
    }
    # Use Terraform Provisioner to install JDK, Maven,Ansible,Docker,AzureCli and Git on VM2, this node will serve as build node
    provisioner "remote-exec" {
		connection {
		type 		= "ssh"
		user 		= var.admin_username
		password 	= var.admin_password
		host 		= azurerm_public_ip.pip[1].ip_address
	    }
    inline = [
	   "export PATH=$PATH:/usr/bin",
		# install java 8
		"sudo apt-get update",
		"sudo apt-get -y install openjdk-8-jdk openjdk-8-jre",
		"export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64",
		"sudo apt-get update",
		"echo $JAVA_HOME",
		"sudo apt-get update",
		"sudo apt-get install -y maven",
		"sudo apt-get install -y docker*",
        "sudo apt-get update",
        "sudo apt-get install software-properties-common",
        "sudo apt-add-repository -y ppa:ansible/ansible",
        "sudo apt-get install ansible -y",
		"sudo apt-get -y install git",
		"curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",		
        ]
        on_failure = continue
    }
}


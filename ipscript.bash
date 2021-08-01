#! /bin/bash

DT=$(date +"%y-%m-%d_%H_%M_%S")
Config_File="/etc/ansible/hosts"
Back_Path="/home/vmadmin/Ansible-hostbak"
V_User="vmadmin"
V_Pwd="VMDocker#123"
Ans_User="ansible_user="

#Taking back up of host file
cp -p $Config_File $Back_Path/hosts_$DT

# Getting Ip of Docker VM
pip=$(az vm list --show-details --output tsv --query "[?name == 'Proj1-VM3'].publicIps")
echo $pip
#getting private ips
#pip=$(az vm show -g Proj1-rg -n Proj1-VM3 --query privateIps -d)
#echo "${pip:1:-1}"

#checking if ip and docker already addeed0

grep $pip $Config_File
if [ $? -eq 0 ]
then
    echo "The Docker host already there in the inventory file"
else
    echo "Adding Docker hosts and $pip in the inventory file"
    echo " [docker] " |  sudo tee -a $Config_File > /dev/null
    echo "$pip" |  sudo tee -a $Config_File > /dev/null  
fi

#ssh -copy-id passing to remote host

sshpass -p $V_Pwd ssh-copy-id -i ~/.ssh/id_rsa.pub $V_User@$pip> /dev/null

echo "Key copied"




























































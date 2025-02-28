#!/bin/zsh
set -e

RESOURCE_GROUP_NAME=sonar-tesseract-rg
LOCATION_NAME=westus2
VM_SSH_KEY_NAME=sonar-tesseract-vm-sshkey
VM_NAME=sonar-tesseract-vm
VM_PUBLIC_IP=sonar-tesseract-public-ip
VM_ADMIN_USERNAME=lord-farquaad
VM_NSG_NAME=sonar-tesseract-nsg
DB_SERVER_NAME=sonar-tesseract-db
DB_ADMIN_USERNAME=shrek
DB_ADMIN_PASSWORD="SecurePassword123"

# Log in to Azure
#az login

# Create the resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION_NAME -o json &> setupResponses/resourceGroupCreateOutput.json

# Wait until the resource group is created
az group wait --name $RESOURCE_GROUP_NAME --created

VM_SIZE=Standard_E2_v4

# Create the VM
az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --location $LOCATION_NAME \
  --admin-username $VM_ADMIN_USERNAME \
  --os-disk-size-gb 30 \
  --public-ip-address $VM_PUBLIC_IP \
  --ssh-key-name ${VM_SSH_KEY_NAME} \
  -o json &> setupResponses/vmCreateOutput.json

# Create the database
POSTGRES_SKU=standard_D96ads_v5
az postgres flexible-server create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $DB_SERVER_NAME \
    --location $LOCATION_NAME \
    --sku-name $POSTGRES_SKU \
    --admin-user $DB_ADMIN_USERNAME \
    --admin-password $DB_ADMIN_PASSWORD -o json &> setupResponses/dbCreateOutput.json

# Create a network security group
az network nsg create \
--resource-group $RESOURCE_GROUP_NAME \
--name $VM_NSG_NAME

# Enable 
az network nsg rule create \
  -g $RESOURCE_GROUP_NAME \
  --nsg-name $VM_NSG_NAME \
  -n allow-SSH \
  --priority 1000 \
  --source-address-prefixes 0.0.0.0/0 \
  --destination-port-ranges 22 \
  --protocol TCP
  
# Connect to the VM
ssh -i $PATH_TO_PUB_KEY $VM_ADMIN_USERNAME@$VM_PUBLIC_IP

# In VM
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $VM_ADMIN_USERNAME

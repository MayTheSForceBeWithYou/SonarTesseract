#!/bin/zsh

RESOURCE_GROUP_NAME=sonar-tesseract-rg

# Delete resource group
az group delete --name $RESOURCE_GROUP_NAME --yes -o json &> cleanupResponses/resourceGroupDeleteOutput.json

# Delete the setup responses
rm setupResponses/*.json

# Delete the cleanup responses
rm cleanupResponses/*.json
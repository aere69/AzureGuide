#!/bin/bash

export RESOURCE_GROUP=WebApp-RG
export AZURE_REGION=uksouth
export AZURE_APP_PLAN=popupappplan-$RANDOM
export AZURE_WEB_APP=popupwebapp-$RANDOM

# List all resource groups
az group list --output table

# Query a specific resource group
az group list --query "[?name == '$RESOURCE_GROUP']"

# 1) Create an App Service Plan (takes a few minutes to complete)
az appservice plan create --name $AZURE_APP_PLAN --resource-group $RESOURCE_GROUP --location $AZURE_REGION --sku FREE

# 2) Verify the service plan was created (list all plans)
az appservice plan list --output table

# 3) Create the web app in the app service plan previously created
az webapp create --name $AZURE_WEB_APP --resource-group $RESOURCE_GROUP --plan $AZURE_APP_PLAN

# 4) Verify the web app was created (list all web appd)
# DefaultHostName = URL address of the website
az webapp list --output table

# list the HTTP address of the webapp
site="http://$AZURE_WEB_APP.azurewebsites.net"
echo $site

# Get the HTML of the sample app.
curl $AZURE_WEB_APP.azurewebsites.net

# 5) Deploy code from GitHub
az webapp deployment source config --name $AZURE_WEB_APP --resource-group $RESOURCE_GROUP --repo-url "https://github.com/Azure-Samples/php-docs-hello-world" --banch maste --manual-integration

# Get the HTML of the sample app.
curl $AZURE_WEB_APP.azurewebsites.net

#!/bin/bash
export location=westus2
export rg=tpc-batch-test-1-rg
export batchAccountName=tpcbatchtest1
export storageAccountName=tpcbatchtest1
echo -e "Location: \t\t" $location
echo -e "Resource Group: \t" $rg
echo -e "Batch Account: \t\t" $batchAccountName
echo -e "Storage Account: \t" $storageAccountName

if [ $(az group exists -n $rg)  != "true" ]
then
    echo -e "creating resource group: \t" $rg    
    az group create -n $rg -l $location
fi

az batch account create -g $rg -n $batchAccountName -l $location > /dev/null

az storage account create -g $rg -n $storageAccountName -l $location --sku Standard_LRS > /dev/null

az batch account set -g $rg -n $batchAccountName --storage-account $storageAccountName > /dev/null


export batchAccountEndpoint="https://"$( az batch account show -g $rg -n $batchAccountName | jq '.accountEndpoint' | tr -d '"')
export storageKey=$(az storage account keys list -g $rg -n $storageAccountName | jq '.[0].value' | tr -d '"')
export batchAccountKey=$(az batch account keys list -g $rg -n $batchAccountName | jq '.primary' | tr -d '"')


export batchAccountEndpoint="https://"$( az batch account show -g $rg -n $batchAccountName | jq '.accountEndpoint' | tr -d '"')
export storageKey=$(az storage account keys list -g $rg -n $storageAccountName | jq '.[0].value' | tr -d '"')
export batchAccountKey=$(az batch account keys list -g $rg -n $batchAccountName | jq '.primary' | tr -d '"')

echo "Updating Credentials:"
echo -e "\tBatch Account Key \t" $batchAccountKey
echo -e "\tBatch Account Endpoint \t" $batchAccountEndpoint
echo -e "\tStorage Account Name \t" $storageAccountName
echo -e "\tStorage Account Key \t" $storageKey


credentials=$(cat ./config_template/credentials.json | jq '.credentials.batch.account_key=env.batchAccountKey' | jq '.credentials.batch.account_service_url=env.batchAccountEndpoint' | jq '.credentials.storage.mystorageaccount.account_key=env.storageKey' | jq '.credentials.storage.mystorageaccount.account=env.storageAccountName' )

echo $credentials > ./config/credentials.json

cp ./config_template/config.json ./config/
cp ./config_template/pool.json ./config/
cp ./config_template/jobs.json ./config/

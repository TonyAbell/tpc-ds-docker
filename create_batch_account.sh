#!/bin/bash


if [ "$1" == "" ]; then
    echo "parameter 1: Scale Factor"
    exit
fi

if [ "$2" == "" ]; then
    echo "parameter 1: Location"
    exit
fi

if [ "$3" == "" ]; then
    echo "parameter 2: Resource Group"
    exit
fi

if [ "$4" == "" ]; then
    echo "parameter 3: Storage Account Name"
    exit
fi

if [ "$5" == "" ]; then
    echo "parameter 4: Container"
    exit
fi

if [ "$6" == "" ]; then
    echo "parameter 5: Storage Account Key"
    exit
fi

storageStr=storage
baseBatchAccountName=tpcdsgen

export scale=$1
export location=$2
export rg=$3
export batchAccountName=$(echo $baseBatchAccountName$RANDOM )
export storageAccountName=$(echo $batchAccountName$storageStr$RANDOM | cut -c1-24)
export destStorageAccountName=$4
export destStorageAccountContainer=$5
export destStorageAccountKey=$6

echo -e "Scale: \t\t" $scale
echo -e "Location: \t\t" $location
echo -e "Resource Group: \t" $rg
echo -e "Batch Account: \t\t" $batchAccountName
echo -e "Storage Account: \t" $storageAccountName

if [ ! -d ./config ]
then
    mkdir ./config
fi

if [ $(az group exists -n $rg)  != "true" ]
then
    echo -e "Creating Group: \t" $rg    
    az group create -n $rg -l $location > /dev/null
fi

echo -e "Creating Batch Account.." 
az batch account create -g $rg -n $batchAccountName -l $location > /dev/null

echo -e "Creating Storage Account.." 
az storage account create -g $rg -n $storageAccountName -l $location --sku Standard_LRS > /dev/null

echo -e "Set Storage Account.." 
az batch account set -g $rg -n $batchAccountName --storage-account $storageAccountName > /dev/null

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


echo "Updating Job:"
echo -e "\tStorage Account Name \t" $destStorageAccountName
echo -e "\tStorage Container \t" $destStorageAccountContainer
echo -e "\tStorage Account Key \t" $destStorageAccountKey

jobs=$( cat ./config_template/jobs.json | jq '.job_specifications[0].environment_variables.storageAccountName=env.destStorageAccountName' | jq '.job_specifications[0].environment_variables.container=env.destStorageAccountContainer' | jq '.job_specifications[0].environment_variables.storageAccountKey=env.destStorageAccountKey' | jq '.job_specifications[0].environment_variables.scale=env.scale' )
echo $jobs > ./config/jobs.json

cp ./config_template/config.json ./config/
cp ./config_template/pool.json ./config/


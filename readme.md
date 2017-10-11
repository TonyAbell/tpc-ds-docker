Read Me
=

Clone This Repo
-

```shell
git clone https://github.com/TonyAbell/tpc-ds-docker.git
```

Install Batch Ship Yard
-

[Batch Shipyard Installation](https://github.com/Azure/batch-shipyard/blob/master/docs/01-batch-shipyard-installation.md)

```shell
git clone https://github.com/Azure/batch-shipyard.git
cd batch-shipyard
./install.sh -3 -e shipyard.venv
```


Create Batch Account
-

Run `create_batch_account.sh` with the following parameters

- Scale: [TPC DS Scale Factor](http://www.tpc.org/tpc_documents_current_versions/current_specifications.asp)
- Location: [Azure Region](https://azure.microsoft.com/en-us/regions/)
- Resource Group: [Azure Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview)
- Storage Account Name: Name of the stoarge account where data will be saved
- Container: The container where the data will be saved
- Storage Account Key: Key for Storage account specified eariler

Exmaple

```shell
./create_batch_account.sh <scale> <location> <resource group> <storage account name> <container> <storage account key>
```

Create Pool & Add Job
-

```shell
SHIPYARD_CONFIGDIR=../tpc-ds-docker/config ./shipyard pool add
SHIPYARD_CONFIGDIR=../tpc-ds-docker/config ./shipyard jobs add --tail stdout.txt
```

Review Data
-

The data will be in your stoarge account / container to be ingested by your tool of choice.
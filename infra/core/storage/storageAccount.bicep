@description('Name of the Storage Account that will be deployed')
param storageAccountName string

@description('The location that the Storage Account will be deployed to')
param location string

@description('The tags that will be applied to the Storage Account')
param tags object

var blobContainerName = 'orderstatestore'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: blobContainerName
  parent: blobService
}

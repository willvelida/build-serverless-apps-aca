@description('The name of the Service Bus namespace that will be deployed')
param serviceBusName string

@description('The location that the Service Bus namespace will be deployed to')
param location string

@description('The name of the Key Vault that will store secrets from Service Bus')
param keyVaultName string

@description('The tags that will be applied to the Service Bus namespace')
param tags object

var topicName = 'tasksavedtopic'
var sbConnectionStringSecretName = 'servicebusconnectionstring'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: topicName
  parent: serviceBus
  properties: {
    supportOrdering: true
  }
}

resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: topicName
  parent: topic
  properties: {
    deadLetteringOnFilterEvaluationExceptions: true
    deadLetteringOnMessageExpiration: true
    maxDeliveryCount: 10
  }
}

var serviceBusEndpoint = '${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey'

resource sbConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: sbConnectionStringSecretName
  parent: keyVault
  properties: {
    value: listKeys(serviceBusEndpoint, serviceBus.apiVersion).primaryConnectionString
  }
}

@description('The endpoint for the Service Bus namespace')
output endpoint string = serviceBus.properties.serviceBusEndpoint

@description('The name of the Service Bus namespace')
output name string = serviceBus.name

@description('The name of the Service Bus namespace that will be deployed')
param serviceBusName string

@description('The location that the Service Bus namespace will be deployed to')
param location string

@description('The name of the Key Vault that will store secrets from Service Bus')
param keyVaultName string

@description('The tags that will be applied to the Service Bus namespace')
param tags object

var topicName = 'tasksavedtopic'
var serviceBusTopicAuthorizationRuleName = 'tasksavedtopic-manage-policy'
var serviceBusTopicAuthRuleSecretName = 'taskedsavedtopic'

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

resource serviceBusTopicAuthRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2021-11-01' = {
  name: serviceBusTopicAuthorizationRuleName
  parent: topic
  properties: {
    rights: [
      'Manage'
      'Send'
      'Listen'
    ]
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

resource serviceBusTopicAuthRuleSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: serviceBusTopicAuthRuleSecretName
  parent: keyVault
  properties: {
    value: serviceBusTopicAuthRule.listKeys().primaryConnectionString
  }
}

@description('The endpoint for the Service Bus namespace')
output endpoint string = serviceBus.properties.serviceBusEndpoint

@description('The name of the Service Bus namespace')
output name string = serviceBus.name

@description('The name of the topic created in this module')
output topicName string = topic.name

@description('The name of the subscription created in this module')
output subscriptionName string = subscription.name

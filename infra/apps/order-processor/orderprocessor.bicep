@description('The name of the Container App Environment that this Container App will be deployed to.')
param containerAppEnvName string

@description('The location that this Container App will be deployed to.')
param location string

@description('The name of the Container Registry that this Container App will pull images from.')
param containerRegistryName string

@description('Specifies the docker container image to deploy.')
param orderProcessorImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('The name of the Key Vault that this Container App will use to pull secrets from')
param keyVaultName string

@description('The name of the Service Bus that this Container App will use for Pub/Sub')
param serviceBusName string

@description('The name of the Cosmos DB account that this Container App will use for State Store')
param cosmosDbName string

@description('The name of the Cosmos DB database that this Container App will use')
param databaseName string

@description('The name of the Cosmos DB container that this Container App will use')
param containerName string

@description('The tags that will be applied to the Container App')
param tags object

var containerAppName = 'order-processor'
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var keyVaultSecretUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var serviceBusDataSenderRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = {
  name: containerAppEnvName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusName
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbName
}

resource sbDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2023-11-02-preview' = {
  name: 'pubsub'
  parent: containerAppEnv
  properties: {
    componentType: 'pubsub.azure.servicebus.topics'
    version: 'v1'
    ignoreErrors: false
    metadata: [
      {
        name: 'namespaceName'
        value: serviceBus.properties.serviceBusEndpoint
      }
      {
        name: 'azureClientId'
        value: orderprocessor.identity.principalId
      }
    ]
    scopes: [
      orderprocessor.name
    ]
  }
}

resource cosmosDaprComponent 'Microsoft.App/managedEnvironments/daprComponents@2023-11-02-preview' = {
  name: 'state-store'
  parent: containerAppEnv
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    ignoreErrors: false
    metadata: [
      {
        name: 'url'
        value: cosmosDb.properties.documentEndpoint
      }
      {
        name: 'database'
        value: databaseName
      }
      {
        name: 'collection'
        value: containerName
      }
      {
        name: 'azureClientId'
        value: orderprocessor.identity.principalId
      }
    ]
  }
}

resource orderprocessor 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      dapr: {
        enabled: true
        appId: containerAppName
        appProtocol: 'http'
        appPort: 5001
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          identity: 'system'
        }
      ]
      secrets: [
        {
          name: 'servicebus-connection-string'
          keyVaultUrl: 'https://${keyVault.name}.vault.azure.net/secrets/servicebusconnectionstring'
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: orderProcessorImage
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
        rules: [
          {
            name: 'topic-based-scaling'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                topicName: 'orders'
                subscriptionName: 'orders'
                messageCount: '30'
              }
              auth: [
                {
                  secretRef: 'servicebus-connection-string'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, orderprocessor.id, keyVaultSecretUserRoleId)
  scope: keyVault
  properties: {
    principalId: orderprocessor.identity.principalId
    roleDefinitionId: keyVaultSecretUserRoleId
    principalType: 'ServicePrincipal'
  }
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, orderprocessor.id, acrPullRoleId)
  scope: containerRegistry
  properties: {
    principalId: orderprocessor.identity.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}

resource serviceBusSenderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBus.id, orderprocessor.id, serviceBusDataSenderRole)
  scope: serviceBus
  properties: {
    principalId: serviceBus.identity.principalId
    roleDefinitionId: serviceBusDataSenderRole
    principalType: 'ServicePrincipal'
  }
}

module sqlRoleAssignment '../../core/database/sql-role-assignment.bicep' = {
  name: 'sqlRoleAssignment'
  params: {
    cosmosDbAccountName: cosmosDb.name
    principalId: orderprocessor.identity.principalId
  }
}

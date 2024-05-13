@description('The name of the Container App Environment that the Dapr Components will be registered to')
param containerAppEnvironment string

@description('The name of the Cosmos DB account')
param cosmosDbAccountName string

@description('The name of the Cosmos DB database')
param cosmosDbDatabaseName string

@description('The name of the Cosmos DB container')
param cosmosDbContainerName string

@description('The name of the Service Bus namespace')
param serviceBusName string

@description('The name of the Backend API service')
param backendApiName string

@description('The name of the Backend processor service')
param backendProcessorName string

resource env 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppEnvironment
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbAccountName
}

resource stateStore 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = {
  name: 'statestore'
  parent: env
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    secrets: [
      
    ]
    metadata: [
      {
        name: 'url'
        value: cosmosDb.properties.documentEndpoint
      }
      {
        name: 'database'
        value: cosmosDbDatabaseName
      }
      {
        name: 'collection'
        value: cosmosDbContainerName
      }
    ]
    scopes: [
      backendApiName
    ]
  }
}

resource pubSub 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = {
  name: 'dapr-pubsub-servicebus'
  parent: env
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    secrets: [
      
    ]
    metadata: [
      {
        name: 'namespaceName'
        value: '${serviceBusName}.servicebus.windows.net'
      }
      {
        name: 'consumerID'
        value: backendProcessorName
      }
    ]
    scopes: [
      backendApiName
      backendProcessorName
    ]
  }
}

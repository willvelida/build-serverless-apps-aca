@description('The name of the Cosmos DB account')
param cosmosAccountName string

@description('The location that the Cosmos DB account will be deployed to')
param location string

@description('The tags that will be applied to the Cosmos DB account')
param tags object

var databaseName = 'tasksmanagerdb'
var containerName = 'taskscollection'

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: cosmosAccountName
  location: location
  tags: tags
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    } 
    locations: [
      {
        locationName: location
        isZoneRedundant: false
        failoverPriority: 0
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
  name: databaseName
  parent: account
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  name: containerName
  parent: database
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/orderId'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

@description('The name of the Cosmos DB account that will be deployed')
output name string = account.name

@description('The name of the Cosmos DB database that will be deployed')
output dbName string = database.name

@description('The name of the Cosmos DB container that will be deployed')
output containerName string = container.name

@description('The suffix applied to all resources')
param appSuffix string = uniqueString(resourceGroup().id)

@description('The location that all resources will be deployed to. Default is the location of the resource group')
param location string = resourceGroup().location

@description('The name applied to the Application Insights workspace')
param appInsightsName string = 'appins-${appSuffix}'

@description('The name applied to the Log Analytics workspace.')
param logAnalyticsName string = 'law-${appSuffix}'

@description('The name of the Container App Environment')
param containerAppEnvName string = 'env-${appSuffix}'

@description('The name of the Container Registry')
param containerRegistryName string = 'acr${appSuffix}'

@description('The name applied to the Key Vault')
param keyVaultName string = 'kv${appSuffix}'

@description('The name applied to the Service Bus namespace')
param serviceBusName string = 'sb-${appSuffix}'

@description('The name of the Cosmos DB account')
param cosmosDbAccountName string = 'db-${appSuffix}'

var tags = {
  Environment: 'Prod'
  Application: 'Serverless-on-Container-Apps'
}

module logAnalytics 'core//monitor/logAnalytics.bicep' = {
  name: 'law'
  params: {
    location: location 
    logAnalyticsWorkspaceName: logAnalyticsName
    tags: tags
  }
}

module appInsights 'core/monitor/appInsights.bicep' = {
  name: 'appins'
  params: {
    appInsightsName: appInsightsName 
    location: location
    logAnalyticsName: logAnalytics.outputs.name
    tags: tags
  }
}

module containerRegistry 'core/host/containerRegistry.bicep' = {
  name: 'acr'
  params: {
    containerRegistryName: containerRegistryName
    location: location
    tags: tags
  }
}

module env 'core/host/containerAppEnvironment.bicep' = {
  name: 'env'
  params: {
    appInsightsName: appInsights.outputs.name
    containerAppEnvironmentName: containerAppEnvName 
    location: location
    logAnalyticsName: logAnalytics.outputs.name 
    tags: tags
  }
  dependsOn: [
    serviceBus
    cosmosDb
  ]
}

module keyVault 'core/security/keyVault.bicep' = {
  name: 'kv'
  params: {
    keyVaultName: keyVaultName 
    location: location
    tags: tags
  }
}

module serviceBus 'core/messaging/serviceBus.bicep' = {
  name: 'sb'
  params: {
    location: location 
    serviceBusName: serviceBusName 
    tags: tags
    keyVaultName: keyVault.outputs.name
  }
}

module cosmosDb 'core/database/cosmosDb.bicep' = {
  name: 'cosmos'
  params: {
    cosmosAccountName: cosmosDbAccountName
    location: location
    tags: tags
  }
}

module frontend 'apps/frontend/frontend.bicep' = {
  name: 'frontend'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName 
    containerRegistryName: containerRegistry.outputs.name
    location: location
    tags: tags
  }
}

module orderprocess 'apps/order-processor/orderprocessor.bicep' = {
  name: 'orderprocessor'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName 
    containerRegistryName: containerRegistry.outputs.name
    keyVaultName: keyVault.outputs.name
    location: location
    serviceBusName: serviceBus.outputs.name
    cosmosDbName: cosmosDb.outputs.name
    databaseName: cosmosDb.outputs.dbName
    containerName: cosmosDb.outputs.containerName
    tags: tags
  }
}

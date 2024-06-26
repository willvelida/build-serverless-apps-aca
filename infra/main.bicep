@description('The suffix applied to all resources')
param appSuffix string = uniqueString(resourceGroup().id)

@description('The location that all resources will be deployed to. Default is the location of the resource group')
param location string = resourceGroup().location

@description('The name applied to the Application Insights workspace')
param appInsightsName string = 'appins-tm-${appSuffix}'

@description('The name applied to the Log Analytics workspace.')
param logAnalyticsName string = 'law-tm-${appSuffix}'

@description('The name of the Container App Environment')
param containerAppEnvName string = 'env-tm-${appSuffix}'

@description('The name of the Container Registry')
param containerRegistryName string = 'acrtm${appSuffix}'

@description('The name of the Key Vault')
param keyVaultName string = 'kv-tm-${appSuffix}'

@description('The name of the Cosmos DB account')
param cosmosDbAccountName string = 'cosmos-tm-${appSuffix}'

@description('The name of the Service Bus namespace')
param serviceBusName string = 'sb-tm-${appSuffix}'

@description('The container image used by the Backend API')
param backendApiImage string

@description('The container image used by the Frontend UI')
param frontendUIImage string

@description('The container image used by the Backend Processor')
param backendProcessorImage string

var tags = {
  Environment: 'Prod'
  Application: 'Task-Manager'
}

module logAnalytics 'core/monitor/logAnalytics.bicep' = {
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
    keyVaultName: keyVault.outputs.name
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

module keyVault 'core/security/keyVault.bicep' = {
  name: 'kv'
  params: {
    keyVaultName: keyVaultName
    location: location
    tags: tags
  }
}
module cosmosDb 'core/database/cosmosDb.bicep' = {
  name: 'cosmosdb'
  params: {
    cosmosAccountName: cosmosDbAccountName
    location: location
    tags: tags
  }
}

module serviceBus 'core/messaging/serviceBus.bicep' = {
  name: 'service-bus'
  params: {
    keyVaultName: keyVault.outputs.name
    location: location
    serviceBusName: serviceBusName
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
}

module dapr 'core/host/daprComponents.bicep' = {
  name: 'dapr'
  params: {
    backendApiName: backendApi.outputs.name 
    backendProcessorName: backendProcessor.outputs.name
    containerAppEnvironment: env.outputs.containerAppEnvName
    cosmosDbAccountName: cosmosDb.outputs.name
    cosmosDbContainerName: cosmosDb.outputs.containerName
    cosmosDbDatabaseName: cosmosDb.outputs.dbName
    serviceBusName: serviceBus.outputs.name
  }
}

module backendApi 'apps/backend-api/backendApi.bicep' = {
  name: 'backend-api'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    containerRegistryName: containerRegistry.outputs.name
    imageName: backendApiImage
    keyVaultName: keyVault.outputs.name
    cosmosDbName: cosmosDb.outputs.name
    cosmosDbCollection: cosmosDb.outputs.containerName
    cosmosDbDatabase: cosmosDb.outputs.dbName
    location: location
    tags: tags
  }
}

module backendProcessor 'apps/backend-processor/backendProcessor.bicep' = {
  name: 'backend-processor'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    containerRegistryName: containerRegistry.outputs.name
    imageName: backendProcessorImage
    keyVaultName: keyVault.outputs.name
    location: location
    tags: tags
  }
}

module frontEnd 'apps/frontend/frontend.bicep' = {
  name: 'frontend'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    containerRegistryName: containerRegistry.outputs.name
    keyVaultName: keyVault.outputs.name
    imageName: frontendUIImage
    backendFqdn: backendApi.outputs.fqdn
    location: location
    tags: tags
  }
}

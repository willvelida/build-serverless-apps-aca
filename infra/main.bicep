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

@description('The name applied to the Storage Account')
param storageAccountName string = 'stor${appSuffix}'

@description('The name applied to the APIM instance')
param apimName string = 'apim-${appSuffix}'

@description('The name applied to the Key Vault')
param keyVaultName string = 'kv-${appSuffix}'

@description('The email address for APIM')
param publishEmailAddress string

@description('The name of the publisher for APIM')
param publisherName string

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
}

module storageAccount 'core//storage/storageAccount.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
    tags: tags
  }
}

module apim 'core/gateway/apim.bicep' = {
  name: 'apim'
  params: {
    apimName: apimName 
    appInsightsName: appInsights.outputs.name
    location: location
    publisherEmail: publishEmailAddress
    publisherName: publisherName
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

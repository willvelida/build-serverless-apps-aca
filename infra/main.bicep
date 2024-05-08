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

module backendApi 'apps/backend-api/backendApi.bicep' = {
  name: 'backend-api'
  params: {
    containerAppEnvName: env.outputs.containerAppEnvName
    containerRegistryName: containerRegistry.outputs.name
    location: location
    tags: tags
  }
}

@description('The name applied to the APIM instance')
param apimName string

@description('The location that the APIM will be deployed to.')
param location string

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('The tags applied to the APIM instance')
param tags object

@description('The App Insights that this APIM instance will send logs to')
param appInsightsName string

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    capacity: 0
    name: 'Consumption'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource apiLogger 'Microsoft.ApiManagement/service/loggers@2023-05-01-preview' = {
  name: 'app-insights-logger'
  parent: apim
  properties: {
    loggerType: 'applicationInsights'
    description: 'Logger to Application Insights'
    isBuffered: false
    resourceId: appInsights.id
  }
}

@description('The name of the created APIM instace')
output name string = apim.name

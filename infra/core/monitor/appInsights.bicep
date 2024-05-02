@description('The name of the Application Insights workspace that will be deployed.')
param appInsightsName string

@description('The location that the Application Insights workspace will be deployed')
param location string

@description('The name of the Log Analytics workspace that will be linked to this Applciation Insights workspace.')
param logAnalyticsName string

@description('The tags that will be applied to the Application Insights workspace')
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  tags: tags
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

@description('The name of the Application Insights workspace')
output name string = appInsights.name

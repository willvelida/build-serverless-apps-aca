@description('The location where the Backend API will be deployed to')
param location string

@description('The Container App environment that the Container App will be deployed to')
param containerAppEnvName string

@description('The tags that will be applied to the Backend API')
param tags object

var containerAppName = 'tasksmanager-backend-api'

resource env 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = {
  name: containerAppEnvName
}

resource backendApi 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: true
        targetPort: 80
        transport: 'http'
      }
      dapr: {
        appId: containerAppName
        enableApiLogging: true
        enabled: true
        appProtocol: 'http'
        appPort: 80
        logLevel: 'info'
      }
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'http-scale-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
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

@description('The FQDN for the Backend API')
output fqdn string = backendApi.properties.configuration.ingress.fqdn

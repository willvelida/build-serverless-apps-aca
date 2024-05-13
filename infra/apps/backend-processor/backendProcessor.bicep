@description('The location where the Backend Processor will be deployed to')
param location string

@description('The Container App environment that the Container App will be deployed to')
param containerAppEnvName string

@description('The tags that will be applied to the Backend Processor')
param tags object

var containerAppName = 'tasksmanager-backend-processor'

resource env 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = {
  name: containerAppEnvName
}

resource backendProcessor 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
      dapr: {
        enableApiLogging: true
        enabled: true
        appId: containerAppName
        appPort: 8080
        logLevel: 'info'
      } 
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: 'mcr.microsoft.com/k8se/quickstart:latest'
          env: [
            
          ]
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        maxReplicas: 1
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

@description('The name of the Backend Processor')
output name string = backendProcessor.name

@description('The FQDN of the Backend Processor')
output fqdn string = backendProcessor.properties.configuration.ingress.fqdn

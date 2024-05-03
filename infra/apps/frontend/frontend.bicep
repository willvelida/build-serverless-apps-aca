@description('The name of the Container App Environment that this Container App will be deployed to.')
param containerAppEnvName string

@description('The location that this Container App will be deployed to.')
param location string

@description('The name of the Container Registry that this Container App will pull images from.')
param containerRegistryName string

@description('Specifies the docker container image to deploy.')
param frontendImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('The tags that will be applied to the Container App')
param tags object

var containerAppName = 'frontend'
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = {
  name: containerAppEnvName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource frontend 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
   managedEnvironmentId: containerAppEnv.id
   configuration: {
    activeRevisionsMode: 'Multiple'
    ingress: {
      external: true
      targetPort: 80
      transport: 'http'
    }
    dapr: {
      appId: containerAppName
      enabled: true
      enableApiLogging: true
      appProtocol: 'http'
      appPort: 3000
    }
    registries: [
      {
        server: '${containerRegistry.name}.azurecr.io'
        identity: 'system'
      }
    ]
   }
   template: {
    containers: [
      {
        name: containerAppName
        image: frontendImage
        env: [
          
        ]
        resources: {
          cpu: json('0.5')
          memory: '1.0Gi'
        }
      }
    ]
    scale: {
      minReplicas: 1
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

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, frontend.id, acrPullRoleId)
  scope: containerRegistry
  properties: {
    principalId: frontend.identity.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
  }
}

output fqdn string = frontend.properties.configuration.ingress.fqdn

// ============================================================================
// Module 1: Deploy a static website with Azure Blob Storage
// Source: Tutorial - Host a static website on Blob Storage
// ============================================================================


@description('Name of the storage account(must be globally unique)')
param StorageaccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('azure region for the storage account')
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {

  name: StorageaccountName
  location: location

  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties:{
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    
  }
}

output storageaccountname string = storageAccount.name

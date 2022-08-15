param location string = resourceGroup().location
param accname string

resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
   name: accname
   location: location
   sku: {
     name: 'Standard_LRS'
   }
   kind: 'StorageV2'
   properties: {
     accessTier: 'Hot'
   }
}

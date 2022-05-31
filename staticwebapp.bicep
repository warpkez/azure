param StaticWebAppName string = 'Demo'

@allowed([
    'westus'
    'centralus'
    'eastus2'
    'westeurope'
    'eastasia'

  ])
param Location string = 'eastasia'
param skuName string = 'Free'
param skuTier string = 'Free'

// Tags for resources
// Get the current datetime 
param BaseDate string = utcNow('u')

// Sets the time for UTC +10
var DateCreated = dateTimeAdd(BaseDate, 'PT10H')

// Resource tags
// Add any and all resource tags here
var ResourceTags =  {
  DateCreated: DateCreated
}

resource staticwebapp 'Microsoft.Web/staticSites@2021-03-01' = {
  name: StaticWebAppName
  location: Location
  tags: ResourceTags

  sku: {
    name: skuName
    tier: skuTier
  }

  properties: {
    buildProperties: {
      skipGithubActionWorkflowGeneration: true
    }
  }
}

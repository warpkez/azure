# Azure BICEP scripts

- pihole-template.bicep - template to generate a virtual machine running the latest Ubuntu release capable of hosting a PiHole configuration.
- staticwebapp.bicep - template to create an empty static web app on the free tier.
- storage.bicep - template to create a LRS hot tier storage account.
- vnet.bicep - template to create a virtual network with subnet.
- resourcegroup.bicep - template to create a resource group for a subscription

## To use templates
`az deployment group create --resource-group {resource group } --template-file { template.bicep } --parameters { parameters.json }`

The PiHole template allows for new and existing configurations via the command line or through the parameters file:

`az deployment group create ----resource-group {resource group } --template-file pihole-template.bicep --parameters { parameters.json } --New_or_Existing_Vnet { new | exisiting }`


Whilst support for remote scripts is unavailable in the current build of bicep it will be necessary to download the files and execute them locally.

# Azure BICEP scripts

This is a collection of BICEP scripts for creating Azure resources.

Predominately it covers the creation of virtual networks and virtual machines as this is my use case, but as I automate more resourse
creation I will add those scripts.

Currently I have in use
- pihole-template.bicep - template to generate a virtual machine running the latest Ubuntu release capable of hosting a PiHole configuration.
- linuxvm.bicep - template to create a Linux VM using the latest 22.04 release of Ubuntu with only SSH and Temporary SSH port access
- staticwebapp.bicep - template to create an empty static web app on the free tier.
- storage.bicep - template to create a LRS hot tier storage account.
- vnet.bicep - template to create a virtual network with subnet.
- resourcegroup.bicep - template to create a resource group for a subscription

## To use templates
`az deployment group create --resource-group {resource group } --template-file { template.bicep } --parameters { parameters.json }`

The PiHole template allows for new and existing configurations via the command line or through the parameters file:

`az deployment group create ----resource-group {resource group } --template-file pihole-template.bicep --parameters { parameters.json } --New_or_Existing_Vnet { new | exisiting }`

To pass parameters to the deployment, a JSON file can be used or they can be passed at the command line for example

`-- parameter ParameterName='Value'`

Whilst support for remote scripts is unavailable in the current build of bicep it will be necessary to download the files and execute them locally.

// Global parameters
// Is this a new or an existing Virtual Network and Subnet
// The default is 'new' for a new deployment, otherwise 'existing' should be
// passed otherwise the deployment will fail if the Virtual Network
// and the Subnet have already been defined with the same Suffix
@allowed([
  'new'
  'existing'
])
@description('New or existing Virtual Network and Subnet')
param New_Or_Existing_VNet string

// Name of VM
param VMName string = 'LinuxVM'

// Username for the default root pleb account
param adminUsername string = 'azuser'

// Strictly define the use of a public key over 'password'
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'sshPublicKey'

// When prompted paste the abcxyz.pub publickey into the console
// This is generated via ssh-keygen console command.
// Remember to covert the private key via putty-keygen if using putty
@secure()
param adminPasswordOrKey string

// Uses the resource group's location to set the location for all resources
param Location string = resourceGroup().location

// Suffix for resources
param Suffix string = 'HomeLab'

// Tags for resources
// Get the current datetime 
param BaseDate string = utcNow('u')

// Sets the time for UTC +10
var DateCreated = dateTimeAdd(BaseDate, 'PT10H')

// Resource tags
// Add any and all resource tags here
var ResourceTags =  {
  DateCreated: DateCreated
  AssociatedVM: VMName
  ResourceFunction: Suffix
}

// Virtual Network
// Virtual network name
param vNetNameBase string = 'vNet01'
var vNetName = toLower('${vNetNameBase}-${Suffix}')

// Address space for the virtual network
param NetworkAddressSpace string = '10.0.0.0/16'

//  Subnet section
// Virtual subnet name
param SubnetNameBase string = 'Subnet01'
var SubnetName = toLower('${SubnetNameBase}-${Suffix}')

// Virtual network address space
param SubnetAddressSpace string = '10.0.0.0/24'

//  Network Security groups
// Network Security Group Name
param SecurityGroupNameBase string = 'NSG01'
var SecurityGroupName = toLower('${SecurityGroupNameBase}-${VMName}')

// Allowed Source IP addresses 
param AllowedSourceIP string = '*'

// NIC Confiuration
// NIC device name
param NicNameBase string = 'NIC01'
var NicName = toLower('${NicNameBase}-${VMName}')

var IpConfig = toLower('ipconfig-${VMName}')
// Public IP Address name
param PublicIPNameBase string = 'PublicIP01'
var PublicIpName = toLower('${PublicIPNameBase}-${VMName}')

// How is the Public internet facing IP address obtained
@allowed([
  'Static'
  'Dynamic'
])
param PublicIPDHCP string = 'Dynamic'

// How is the private internal IP address obtained
@allowed([
  'Static'
  'Dynamic'
])
param PrivateIPDHCP string = 'Dynamic'

//  VM Details
// VM Sizes.  
// A warning is given for Standard_B1ls as it is not listed in the current version of the helper
@allowed([
  'Standard_B1ls'
  'Standard_B1s'
  'Standard_B1ms'
  'Standard_B2s'
])
param VMSize string = 'Standard_B1ls'

// Which release of Ubuntu
//@allowed([
//  '12.04.5-LTS'
//  '14.04.5-LTS'
//  '16.04.0-LTS'
//  '18.04-LTS'
//  '20_04-lts-gen2'
//])

@allowed([
  '0001-com-ubuntu-server-jammy'
  '0001-com-ubuntu-server-focal'
])
param skuOffer string = '0001-com-ubuntu-server-focal'

@allowed([
  '20_04-lts-gen2'
  '22_04-lts-gen2'
])
param ubuntuOSVersion string = '20_04-lts-gen2'

param ubuntuReleaseVersion string = 'latest'
//
//  Suffixes, prefixes, and other descriptive variables
//

// OsDisk configured for local redundant storage
var osDiskType = 'Standard_LRS'

// Configuation set to use PublicKey
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

var imageReference = {
  publisher: 'canonical'
  offer: skuOffer
  sku: ubuntuOSVersion
  version: ubuntuReleaseVersion
}

// Virtual network will be associated with the resource group
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = if (toLower(New_Or_Existing_VNet) == 'new') {
//resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vNetName
  location: Location
  tags: ResourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
       NetworkAddressSpace 
      ]
    }
  }
}

// Subnet will be associated with the resource group
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (toLower(New_Or_Existing_VNet) == 'new') {
//resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: SubnetName
  parent: vnet
  properties: {
    addressPrefix: SubnetAddressSpace
  } 
}

// Network Security Group will be associated with the virtual machines and
// assigned to the NIC rather than the subnet
// Allow all ports for a PiHole configuration
// Ports 22, 80 and 443, 53, and ICMP
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
 name: SecurityGroupName
 location: Location
 tags: ResourceTags
 properties: {
   securityRules: [
     {
       name: 'SSH'
       properties: {
         protocol: 'Tcp'
         direction: 'Inbound'
         access: 'Allow'
         priority: 100
         sourceAddressPrefix: AllowedSourceIP
         sourcePortRange: '*'
         destinationAddressPrefix: '*'
         destinationPortRanges: [
           '22'
           '1022'
         ]
       }
     }
     {
       name: 'HTTP_HTTPS'
       properties: {
         protocol: 'Tcp'
         direction: 'Inbound'
         access: 'Allow'
         priority: 101
         sourceAddressPrefix: AllowedSourceIP
         sourcePortRange: '*'
         destinationAddressPrefix: '*'
         destinationPortRanges: [
            '80'
            '443'
         ]
       }
     }     
     {
      name: 'DNS'
      properties: {
        protocol: 'Udp'
        direction: 'Inbound'
        access: 'Allow'
        priority: 103
        sourceAddressPrefix: AllowedSourceIP
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '53'
       }
     }
     {
      name: 'ICMP'
      properties: {
        protocol: 'Icmp'
        direction: 'Inbound'
        access: 'Allow'
        priority: 104
        sourceAddressPrefix: AllowedSourceIP
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '*'
       }
     }
   ]
 }
} 

// Associate the NIC with the VM and apply subnet and NSGs
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: NicName
  location: Location
  tags: ResourceTags
  properties:{
   ipConfigurations: [
     {
       name: IpConfig
       properties: {
         subnet: {
           id: subnet.id
         }
         privateIPAllocationMethod: PrivateIPDHCP
         publicIPAddress: {
           id: publicIP.id
         }
       }
     }
   ]
   networkSecurityGroup: {
     id: nsg.id
   }
  }
}

// Assign a public IP address so the VM can be accessed over the internet
resource publicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: PublicIpName
  tags: ResourceTags
  location: Location
  sku: {
    name:'Basic'
  }
  properties: {
    publicIPAllocationMethod: PublicIPDHCP
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}  

// Create the virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: VMName
  tags: ResourceTags
  location: Location

  properties: {
    hardwareProfile: {
      // This is not really an error.
      // The bicep library has not been updated with
      // the Linux only Standard_B1ls records
      // 2022 05 05
      vmSize: VMSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }

      imageReference: imageReference
    }
    networkProfile: {
      networkInterfaces: [
       {
         id: nic.id
       }
      ]
    }
    osProfile: {
      computerName: VMName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: any((authenticationType == 'password') ? null : linuxConfiguration)
    }
  }
}

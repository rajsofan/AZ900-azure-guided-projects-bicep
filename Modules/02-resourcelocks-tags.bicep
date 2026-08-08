//This Bicep File deploys a VM and adds resource Locks and Tags
//Creates:Vnet_Subnets,NIC,VM applies Lab tags and delete lock on the VM

@description('Name of the virtual Network')
param vnetName string = 'project-vnet1'

@description('Location of the Vnet')
param location string = resourceGroup().location

@description('Deparment tag value for the Vnet')
param vnetDepartmentTag string = 'IT'

@description( 'Address Space for the Vnet')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Name of the Subent')
param subentName string = 'subnet-1'

@description('Address Prefix for the subnet')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('Name of the virtual machine')
param vmName string = 'VM1'

@description('Size of the VM')
param vmSize string = 'Standard_B2S'

@description('Admin Username for the VM')
param adminusername string = 'adminuser'

@description('Admin password for the VM')
@secure()
param adminPassword string

@description('Department Tag value for the VM')
param vmDepartmentTag string = 'Customer Service'

@description('Purpose tag value for the VM')
param vmpurposeTag string = 'FTP Server'

@description('Name of the delete lock applied to the VM')
param vmLockName string = 'VM-delete-Lock'

//create Virtual Network

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01'= {
  
  name: vnetName
  location: location
  tags:{
    Department:vmDepartmentTag
  }
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetAddressPrefix
      ]}
      subnets: [
        {
          name:subentName
          properties:{
            addressPrefix:subnetAddressPrefix
            networkSecurityGroup:{
              id:nsg.id
            } 
           }
        }
      ]
    
  }
  
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  name: '${vmName}-nsg'
  location:location

  properties: {
    securityRules: [
      { name: 'Allow-RDP'
        properties: {
          priority: 100
          direction:'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange:'*'
          destinationPortRange:'3389'
          destinationAddressPrefix:'*'
          sourceAddressPrefix: '*'
        }
    }
    ]
  }
}
 resource publiIP 'Microsoft.Network/publicIPAddresses@2025-07-01' = {

  name: '${vmName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
   properties: {
    publicIPAllocationMethod: 'Static'
   }
 }

 resource nic 'Microsoft.Network/networkInterfaces@2025-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publiIP.id
          }
        }
      }
    ]
  }
}

 resource vm 'Microsoft.Compute/virtualMachines@2026-03-01' = {
  name: vmName
  location: location
  tags: {
    Department: vmDepartmentTag
    Purpose:vmpurposeTag
  }
  properties: {
    hardwareProfile:{
      vmSize:vmSize
    }
    osProfile: {
      computerName:vmName
      adminUsername: adminusername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption:'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
 }

  resource vmlock 'Microsoft.Authorization/locks@2020-05-01' = {
    name: vmLockName
    scope:vm
    properties: {
      level: 'CanNotDelete'
      notes:'Prevents accidental deletion of the vm'
    }
  }

  output vmName string = vm.name
  output vnetName string = vnet.name
  output publicIpAddress string = publiIP.properties.ipAddress
  output vmResourceID string = vm.id

# AZ900 Azure Guided Projects - Bicep

This repository contains Azure Infrastructure as Code (IaC) templates written in **Bicep** for AZ900 guided projects. It demonstrates how to deploy Azure resources declaratively using Bicep templates and includes several example modules for common scenarios.

## 📋 Prerequisites

Before using this repository, ensure you have the following installed and configured:

- **Azure CLI**: [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Bicep CLI**: Included with Azure CLI (version 2.3.0 or later)
- **Azure Subscription**: An active Azure subscription with sufficient permissions

## 🚀 Quick Start

### 1. Login to Azure
```bash
az login
```
This command opens your browser to authenticate and access your Azure account.

### 2. Create a Resource Group
```bash
az group create --name rg-gp-static-website --location uksouth
```
Replace `uksouth` with your desired Azure region. Available regions include:
- `eastus`, `westus`, `northeurope`, `westeurope`, `uksouth`, `Southeast Asia`, etc.

### 3. Deploy a Bicep Template (Module 1: Static Website)
```bash
az deployment group create \
  --resource-group rg-gp-static-website \
  --template-file Modules/01-static-website.bicep
```

### 4. Enable Static Website Hosting
```bash
az storage blob service-properties update \
  --account-name <storage-account-name> \
  --auth-mode login \
  --static-website \
  --index-document index.html \
  --404-document 404.html
```
Replace `<storage-account-name>` with the storage account name generated during deployment.

### 5. Get Your Website Endpoint
```bash
az storage account show \
  --name <storage-account-name> \
  --resource-group rg-gp-static-website \
  --query "primaryEndpoints.web"
```
This displays the public URL of your static website.

---

## 📁 Repository Structure

```
AZ900-azure-guided-projects-bicep/
├── README.md                         # Documentation (this file)
├── .gitignore
├── Commands                          # CLI commands reference
└── Modules/
    ├── 01-static-website.bicep       # Bicep template for static website
    └── 02-resourcelocks-tags.bicep   # Bicep template for VM with resource locks & tags
```

## 🏗️ Project Modules

### Module 1: Static Website (01-static-website.bicep)

This module deploys an Azure Storage Account configured for hosting a static website.

**Resources Created:**
- **Azure Storage Account** (StorageV2)
  - SKU: Standard_LRS (Locally Redundant Storage)
  - Access Tier: Hot
  - HTTPS Only: Enabled
  - TLS Version: 1.2 minimum
  - Public Blob Access: Enabled

**Parameters:**
- `StorageaccountName` (string): Name of the storage account (must be globally unique)
  - Default: Auto-generated using `st${uniqueString(resourceGroup().id)}`
- `location` (string): Azure region for deployment
  - Default: Same as resource group location

**Outputs:**
- `storageaccountname`: The name of the created storage account

**Example Deployment:**
```bash
az deployment group create \
  --resource-group rg-gp-static-website \
  --template-file Modules/01-static-website.bicep \
  --parameters StorageaccountName=mystorageaccount location=uksouth
```

---

### Module 2: VM with Resource Locks & Tags (02-resourcelocks-tags.bicep)

This module deploys a simple Windows virtual machine along with networking resources and applies tags and a delete lock to the VM.

**Resources Created:**
- Virtual Network and Subnet
- Network Security Group (NSG) with an RDP rule
- Public IP Address (Static, Standard SKU)
- Network Interface (NIC)
- Virtual Machine (Windows Server 2022)
- Resource Lock (level: CanNotDelete) scoped to the VM
- Tags applied to VNet and VM (Department, Purpose)

**Key Behaviour / Notes:**
- The VM admin password is defined as a secure parameter (no plaintext in templates recommended when deploying).
- The delete lock prevents accidental deletion of the VM resource.

**Parameters (with defaults shown in the module):**
- `vnetName` (string): Name of the virtual network (default: `project-vnet1`)
- `location` (string): Location for resources (default: resource group location)
- `vnetDepartmentTag` (string): Department tag value for the vnet (default: `IT`)
- `vnetAddressPrefix` (string): Address space for VNet (default: `10.0.0.0/16`)
- `subentName` (string): Subnet name (default: `subnet-1`)
- `subnetAddressPrefix` (string): Subnet address prefix (default: `10.0.0.0/24`)
- `vmName` (string): Virtual machine name (default: `VM1`)
- `vmSize` (string): VM size (default: `Standard_B2S`)
- `adminusername` (string): Administrator username (default: `adminuser`)
- `adminPassword` (secure string): Administrator password (no default)
- `vmDepartmentTag` (string): Department tag for VM (default: `Customer Service`)
- `vmpurposeTag` (string): Purpose tag for VM (default: `FTP Server`)
- `vmLockName` (string): Name of the delete lock applied to the VM (default: `VM-delete-Lock`)

**Outputs:**
- `vmName`: Name of the created VM
- `vnetName`: Name of the created VNet
- `publicIpAddress`: Public IP address assigned to the VM
- `vmResourceID`: Resource ID of the VM

**Example Deployment:**
```bash
# Create resource group
az group create --name rg-gp-vmlockandtag --location uksouth

# Deploy the module (you will be prompted for secure parameters unless passed)
az deployment group create \
  --resource-group rg-gp-vmlockandtag \
  --template-file Modules/02-resourcelocks-tags.bicep \
  --parameters adminPassword='<YourSecurePassword>' vmName=myvmname location=uksouth
```

> Security note: For production or shared use, consider using Azure Key Vault or parameter files to provide secrets (adminPassword) instead of passing them directly on the CLI.

---

## 📄 Web Content Setup (for Module 1)

After deploying the infrastructure for the static website, upload your web files:

### Index Page (index.html)
```html
<!DOCTYPE html>
<html>
<head>
  <title>Product Landing Page</title>
</head>
<body>
  <h1>Version 1 - Landing Page</h1>
  <p>Welcome to our product page. This is the initial published version.</p>
</body>
</html>
```

### 404 Error Page (404.html)
```html
<!DOCTYPE html>
<html>
<head>
  <title>Page Not Found</title>
</head>
<body>
  <h1>404 - Page Not Found</h1>
  <p>The page you requested does not exist. Return to the <a href="/">home page</a>.</p>
</body>
</html>
```

**Upload Content:**
```bash
# Upload index.html
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name '$web' \
  --name index.html \
  --file ./index.html

# Upload 404.html
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name '$web' \
  --name 404.html \
  --file ./404.html
```

## 🔧 Common Commands

See the `Commands` file for a quick reference of all CLI commands used in this project (both Module 01 and Module 02 are listed there).

## 💡 Key Features

✅ **Infrastructure as Code**: All resources defined declaratively in Bicep  
✅ **Reusable Modules**: Modular design for easy scaling  
✅ **Best Practices**: HTTPS-only, TLS 1.2 minimum where applicable  
✅ **Cost Efficient**: Uses Standard_LRS for cost-effective storage  
✅ **Global Uniqueness**: Auto-generated storage account names to avoid conflicts

## 📚 Learning Resources

- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Storage Static Website Hosting](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website)
- [AZ900 Certification Study Guide](https://learn.microsoft.com/en-us/certifications/azure-fundamentals/)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)

## 🧹 Cleanup

To avoid charges, delete resources when no longer needed:

```bash
# Delete the static website resource group
az group delete --name rg-gp-static-website --yes --no-wait

# Delete the VM/lab resource group
az group delete --name rg-gp-vmlockandtag --yes --no-wait
```

⚠️ **Warning**: These operations are irreversible and will delete all resources in the resource group.

## 📝 Notes

- Storage account names must be globally unique across all Azure subscriptions
- The repository uses auto-generated names to prevent conflicts
- Ensure you have appropriate Azure RBAC permissions to create resources
- Consider implementing additional security measures for production deployments

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is provided as-is for educational purposes.

---

**Last Updated**: August 2026  
**Bicep Version**: Supported with Azure CLI 2.3.0+

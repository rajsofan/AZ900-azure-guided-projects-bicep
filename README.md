# AZ900 Azure Guided Projects - Bicep

This repository contains Azure Infrastructure as Code (IaC) templates written in **Bicep** for AZ900 guided projects. It demonstrates how to deploy Azure resources declaratively using Bicep templates.

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

### 3. Deploy the Bicep Template
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

## 📁 Repository Structure

```
AZ900-azure-guided-projects-bicep/
├── README.md                      # Documentation (this file)
├── Commands                       # CLI commands reference
└── Modules/
    └── 01-static-website.bicep    # Bicep template for static website
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

## 📄 Web Content Setup

After deploying the infrastructure, upload your web files:

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

See the `Commands` file for quick reference of all CLI commands used in this project.

## 💡 Key Features

✅ **Infrastructure as Code**: All resources defined declaratively in Bicep  
✅ **Reusable Modules**: Modular design for easy scaling  
✅ **Best Practices**: HTTPS-only, TLS 1.2 minimum, Azure best practices  
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
# Delete the entire resource group and all resources within it
az group delete --name rg-gp-static-website --yes --no-wait
```

⚠️ **Warning**: This operation is irreversible and will delete all resources in the resource group.

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

**Last Updated**: July 2026  
**Bicep Version**: Supported with Azure CLI 2.3.0+

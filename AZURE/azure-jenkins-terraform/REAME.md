
# Jenkins on Azure Virtual Machine with Terraform

This project automates the deployment of a Jenkins server on an Ubuntu virtual machine (VM) in Microsoft Azure using Terraform. The VM is configured with Jenkins installed and set up to run as a service.

## Prerequisites

Before you begin, ensure you have the following installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for authentication)
- [SSH Key](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys) (for secure VM access)

## Terraform Configuration

### 1. Provider Configuration

The Terraform script uses the Azure provider to create resources in Azure. You'll need to authenticate using either:
- The Azure CLI (`az login`), or
- A service principal with the appropriate roles (Contributor).

### 2. Virtual Machine Configuration

The VM is provisioned with the following configuration:
- **VM Size**: By default, the VM is set to use `Standard_B1ms` (can be customized).
- **OS**: Ubuntu 22.04 LTS.
- **Jenkins Installation**: Jenkins is installed via a custom script that adds the Jenkins repository, installs Jenkins, and starts it as a service.
- **SSH Access**: Configured using an SSH public key.

### 3. Custom Data Script

A custom data script (`custom_data`) is injected into the VM to automate the installation and setup of Jenkins:

```bash
#!/bin/bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

### 4. Outputs
After running the script, the public IP address of the Jenkins server will be displayed, which you can use to access Jenkins through the browser.

How to Use
### Step 1: Clone the repository
```
git clone <repository_url>
cd <repository_directory>
```

### Step 2: Initialize Terraform
```
terraform init
```
This command will download the required providers and modules.

### Step 3: Configure Your Azure Credentials
Authenticate using the Azure CLI:

```
az login
```
Make sure you have set the correct subscription:

```
az account set --subscription "<SUBSCRIPTION_ID>"
```
Alternatively, configure a service principal in the Terraform provider block.

### Step 4: Update Variables (Optional)
Edit the main.tf file to adjust any settings such as the region (location), VM size (size), and SSH key.

### Step 5: Apply the Terraform Configuration
```
terraform apply
```
Terraform will prompt you to confirm the changes. Type yes to proceed.

### Step 6: Access Jenkins
Once the deployment completes, the public IP of the VM will be output. Open your browser and go to:

```
http://<VM_PUBLIC_IP>:8080
```
### Step 7: Get Jenkins Initial Admin Password
To retrieve the Jenkins initial admin password, SSH into the VM:

```
ssh azureuser@<VM_PUBLIC_IP>
```
Then run:

```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Copy this password and use it to unlock Jenkins.

### Cleanup
To destroy the resources created by Terraform, run:

```
terraform destroy
This will remove all resources created by the Terraform script.
```

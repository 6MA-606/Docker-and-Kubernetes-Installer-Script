
# Docker and Kubernetes Installer Script 🚀

## Overview 📝

This script automates the installation of **Docker** and **Kubernetes** on an Ubuntu system.

## Features ✨

- 🗑️ Uninstalls old Docker versions
- 📦 Installs required dependencies
- 🔑 Configures Docker and Kubernetes repositories
- 🛠️ Installs Docker, Kubernetes (kubeadm, kubelet, kubectl)
- 👤 Adds current user to the Docker group
- ⚙️ Configures **containerd**
- 🚫 Disables swap for Kubernetes compatibility
- 🏗️ Loads necessary kernel modules
- 🔄 Uses **spinners** to indicate task progress

## Prerequisites ✅

- 🐧 **Ubuntu** (Tested on Ubuntu 24.04)
- 🔑 User with `sudo` privileges

## Usage 🖥️

### Option 1: Clone the repository 📂

You can clone the repository and run the script in either **default mode** (silent) or **verbose mode** (detailed output):

#### Default mode (silent output) 🤫

```bash
git clone https://github.com/6MA-606/Docker-and-Kubernetes-Installer-Script.git
cd Docker-and-Kubernetes-Installer-Script
chmod +x install-docker-k8s.sh
./install-docker-k8s.sh
```

#### Verbose mode (shows detailed output) 🔍

```bash
git clone https://github.com/6MA-606/Docker-and-Kubernetes-Installer-Script.git
cd Docker-and-Kubernetes-Installer-Script
chmod +x install-docker-k8s.sh
./install-docker-k8s.sh -v
```

### Option 2: Run the script directly with `curl` 📡

If you don't want to clone the repository, you can directly download and run the script using `curl`:

#### Default mode (silent output) 🤫

```bash
curl -sSL https://gist.githubusercontent.com/6MA-606/339ec3809a1914ea709a982aa0a0d35e/raw/137d8c6e995246cb192ae390a6e48334bf71600f/install-docker-k8s.sh | sudo bash
```

#### Verbose mode (shows detailed output) 🔍

```bash
curl -sSL https://gist.githubusercontent.com/6MA-606/339ec3809a1914ea709a982aa0a0d35e/raw/137d8c6e995246cb192ae390a6e48334bf71600f/install-docker-k8s.sh | sudo bash -s -- -v
```

### Explanation of Modes:

- **Default mode**: Runs the script silently with minimal output. Ideal for automated installations.
- **Verbose mode**: Provides detailed output for each step, helpful for debugging or if you want to see progress.

## Installation Steps 🛠️

This script performs the following steps:

1. 🗑️ **Removes old Docker versions**
2. 🔄 **Updates necessary system packages**
3. 🔑 **Adds Docker and Kubernetes GPG keys & repositories**
4. 🐳 **Installs Docker Engine and CLI**
5. 👥 **Adds user to Docker group**
6. ⚙️ **Configures containerd for Kubernetes compatibility**
7. 🚀 **Installs Kubernetes components (kubeadm, kubelet, kubectl)**
8. 🚫 **Disables swap**
9. 🔧 **Enables required kernel modules**

## Example Output 📜

```bash
[✓] Old Docker Versions Uninstalled Successfully
[✓] Necessary Packages Updated Successfully
[✓] Docker GPG Key Added Successfully
[✓] Docker Repository Added Successfully
[✓] Docker Installed Successfully
[✓] Current User Added to Docker Group Successfully
[✓] Containerd Configured Successfully
[✓] Kubernetes GPG Key Added Successfully
[✓] Kubernetes Installed Successfully
[✓] Kubelet Enabled Successfully
[✓] Swap Disabled Successfully
[✓] Kernel Modules Loaded Successfully

✓✓✓ All Done! ✓✓✓

 You may need to logout and login again to use Docker and Kubernetes.
```

## References 📚

- 🐳 **Docker Installation:** [Docker Docs](https://docs.docker.com/engine/install/ubuntu/)
- ☸️ **Kubernetes Installation:** [Kubernetes Docs](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- 🔗 **Kubernetes Cluster Setup:** [Setting Up a Multi-Node Kubernetes Cluster with kubeadm by Prithiviraj R](https://dev.to/prithiviraj_rengarajan/setting-up-a-multi-node-kubernetes-cluster-with-kubeadm-1788)

## Author ✍️

- **Sittha Manittayakul** ([@6MA-606](https://github.com/6MA-606))

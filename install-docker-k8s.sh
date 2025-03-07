#!/bin/bash

silent_mode=true

if [ "$1" == "-v" ] || [ "$1" == "--verbose" ]; then
    silent_mode=false
fi

# Function to display a dynamic spinner with a custom message
function show_spinner() {
    local pid=$!
    local spin='-\|/'
    local i=0
    local message=$1  # Custom message passed to the spinner
    local done_message=$2  # Message to show when the task is complete

    # Display spinner until the process (pid) finishes
    while kill -0 $pid 2> /dev/null; do
        i=$(( (i+1) %4 ))  # Cycle through spinner characters
        echo -ne "\r[${spin:$i:1}] \033[1m$message\033[0m"  # Show spinner and message
        sleep 0.1  # Optional, just for smoother spinner effect
    done
}

# Function to run a command with the spinner
function run_command_with_spinner() {
    local message=$1
    local done_message=$2
    shift 2
    local command=("$@") # Store the command as an array

    # Run the command in the background and capture its PID
    if [ "$silent_mode" = true ]; then
        "${command[@]}" &> /dev/null & 
    else
        "${command[@]}" & 
    fi
    local pid=$!

    # Show the spinner while the process is running
    show_spinner "$message" $pid

    # Wait for the process to complete and capture the exit code
    wait $pid
    local exit_code=$?

    # Handle success or failure based on the exit code
    if [ $exit_code -ne 0 ]; then
        echo -e "\r[\033[31mX\033[0m] $message Failed"
        exit 1
    else
        echo -e "\r[\033[32m✓\033[0m] \033[90m$done_message\033[0m"
    fi
}

# Uninstall Old Docker Versions
function uninstall_old_docker_versions() {
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
}

# Update and Install Required Tools
function update_packages() {
    sudo apt-get update -y 
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg || { echo -e "\033[31mFailed to Install Required Tools\033[0m"; return 1; }
}

# Add Docker GPG Key
function add_docker_gpg() {
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
}

# Add Docker Repository
function add_docker_apt_repository() {
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
}

# Install Docker
function install_docker() {
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# Add Current User to Docker Group
function add_current_user_to_docker_group() {
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
}

# Configure Containerd
function configure_containerd() {
    sudo mkdir -p /etc/containerd  
    sudo containerd config default | sudo tee /etc/containerd/config.toml  
    sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml  
    sudo systemctl restart containerd  
}

# Add Kubernetes GPG Key
function add_kubernetes_gpg() {
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
}

# Install Kubernetes
function install_kubernetes() {
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
}

# Enable Kubelet
function enable_kubelet() {
    sudo systemctl enable --now kubelet
}

# Disable Swap
function disable_swap() {
    sudo swapoff -a  
    sudo sed -i '/swap/d' /etc/fstab 
}

# Load Kernel Modules
function load_kernel_modules() {
    sudo modprobe br_netfilter  
    sudo sysctl -w net.ipv4.ip_forward=1
}

# Main Function
function run() {

    echo ""
    echo -e "\033[1;33mStarting the Docker and Kubernetes Installation Process...\033[0m"
    echo -e "\n\033[1;33mReference:\033[0m"
    echo -e "\t- Docker Installation: \033[36mhttps://docs.docker.com/engine/install/ubuntu/\033[0m"
    echo -e "\t- Kubernetes Installation: \033[36mhttps://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/\033[0m"
    echo -e "\t- Kubernetes Cluster Setup: \033[36mhttps://dev.to/prithiviraj_rengarajan/setting-up-a-multi-node-kubernetes-cluster-with-kubeadm-1788\033[0m"
    echo ""

    run_command_with_spinner "Uninstalling Old Docker Versions..." "Old Docker Versions Uninstalled Successfully" uninstall_old_docker_versions
    run_command_with_spinner "Updating Necessary Packages..." "Necessary Packages Updated Successfully" update_packages
    run_command_with_spinner "Adding Docker GPG Key..." "Docker GPG Key Added Successfully" add_docker_gpg
    run_command_with_spinner "Adding Docker Repository..." "Docker Repository Added Successfully" add_docker_apt_repository
    run_command_with_spinner "Installing Docker..." "Docker Installed Successfully" install_docker
    run_command_with_spinner "Adding Current User to Docker Group..." "Current User Added to Docker Group Successfully" add_current_user_to_docker_group
    run_command_with_spinner "Configuring Containerd..." "Containerd Configured Successfully" configure_containerd
    run_command_with_spinner "Adding Kubernetes GPG Key..." "Kubernetes GPG Key Added Successfully" add_kubernetes_gpg
    run_command_with_spinner "Installing Kubernetes..." "Kubernetes Installed Successfully" install_kubernetes
    run_command_with_spinner "Enabling Kubelet..." "Kubelet Enabled Successfully" enable_kubelet
    run_command_with_spinner "Disabling Swap..." "Swap Disabled Successfully" disable_swap
    run_command_with_spinner "Loading Kernel Modules..." "Kernel Modules Loaded Successfully" load_kernel_modules

    echo ""
    echo -e "\033[1;32m✓✓✓ All Done! ✓✓✓\033[0m\n\n You may need to logout and login again to use Docker and Kubernetes"
    echo ""

    exit 0
}

# Run the main function
run

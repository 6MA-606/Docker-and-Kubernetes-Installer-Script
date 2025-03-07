#!/bin/bash

join_command=""
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
        echo -e "\r[\033[31mX\033[0m] $message Failed                                             "
        exit 1
    else
        echo -e "\r[\033[32m✓\033[0m] \033[90m$done_message\033[0m                                             "
    fi
}

function clear_old_configurations() {
    sudo kubeadm reset -f
    sudo rm -rf $HOME/.kube
}

function initial_master_node() {
    # Capture the entire output of kubeadm init
    init_output=$(sudo kubeadm init --pod-network-cidr=10.244.0.0/16 2>&1)

    # Print the output to debug if needed
    echo "$init_output"

    # Capture the join command from the output
    join_command=$(echo "$init_output" | grep -A 1 "kubeadm join" | tr -d '\n\t' | sed 's/\\//g')

    # Debugging: Check if join_command was captured
    if [ -z "$join_command" ]; then
        echo "ERROR: join_command not found in the kubeadm init output." >&2
        exit 1
    fi

    # Save join_command to a temp file
    echo "$join_command" > /tmp/join_command.txt
}

function set_up_kube_config() {
    mkdir -p $HOME/.kube  
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

function install_flannel() {
    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
}

# Main Function
function run() {
    echo ""
    echo -e "\033[1;33mStarting the Kubernetes Master Node Setup with Flannel...\033[0m"
    echo -e "\n\033[1;33mReference:\033[0m"
    echo -e "\t- Kubernetes Cluster Setup: \033[36mhttps://dev.to/prithiviraj_rengarajan/setting-up-a-multi-node-kubernetes-cluster-with-kubeadm-1788\033[0m"
    echo ""

    run_command_with_spinner "Clearing Old Configurations" "Old Configurations Cleared" clear_old_configurations
    run_command_with_spinner "Initializing the Kubernetes Master Node" "Kubernetes Master Node Initialized" initial_master_node
    run_command_with_spinner "Setting up kube config" "Kube Config Set" set_up_kube_config
    run_command_with_spinner "Installing Flannel" "Flannel Installed" install_flannel

    # Read join_command from the file
    if [ -f /tmp/join_command.txt ]; then
        join_command=$(cat /tmp/join_command.txt)
        rm -f /tmp/join_command.txt
    fi

    echo ""
    echo -e "\033[1;32m✓✓✓ All Done! ✓✓✓\033[0m\n "
    echo -e "\033[1;33mNext Steps:\033[0m"
    if [ -n "$join_command" ]; then
        echo -e "\t- Run join command on the worker nodes to join the cluster"
        echo -e "\t\t $join_command"
    else
        echo -e "\t- ERROR: Join command could not be retrieved."
    fi
    echo -e "\t- Run \033[36mkubectl get pods --all-namespaces\033[0m to check the status of the pods"
    echo -e "\t- Run \033[36mkubectl get nodes\033[0m to check the status of the nodes"
    echo ""

    exit 0
}


# Run the main function
run

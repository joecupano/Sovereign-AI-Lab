#!/bin/bash

#
# build-sovereign-ai-lab_amd.sh
#
# This script is designed to set up a lab environment for running
# large language models (LLMs) using Ollama on an Ubuntu system. 
#
# 20210220 - 2300
#

INSTALL_COLOR="\e[0;104m\e[K"   # blue
SUCCESS_COLOR="\e[0;42m\e[K"   # green
BANNER_RESET="\e[0m"

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} Build Sovereign AI Lab (AMD GPU)"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "

cat <<'EOF'

Given a fresh Ubuntu 24.04 install, this script sets up the Sovereign AI Lab
environment performing the following in order:

1. Update Repositories
2. Add AMD Repository
3. Install AMD Driver and ROCm Utility
4. Install Build Utilities
5. Install Python Environment and Development Utilities
6. Install Ollama
7. Pull an LLM (IBM Granite 3.3 8B)

Starting ...

EOF

echo "Press any key to continue or Ctrl-C to exit..."
read -n 1 -s -r
echo " "

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 1. Update Repositories"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "
sudo apt update && sudo apt upgrade -y
echo " "

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 2. Add AMD Repository"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "
sudo apt install wget gpg -y
wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key
sudo gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.0/ jammy main"
sudo tee /etc/apt/sources.list.d/rocm.list

echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 3. Install AMD Driver and ROCm Utility"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
sudo apt update
sudo apt install fglrx-core rocm-hip-sdk -y
sudo usermod -aG video \$USER
sudo usermod -aG render \$USER

echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 4. Install Build Utilities"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "
sudo apt install build-essential git gcc cmake curl -y

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 5. Install Python Environment and Development Utilities"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"   
echo " "
sudo apt install python3-pip python3-venv python3-dev -y

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 6. Install Ollama"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "
curl -fsSL https://ollama.com/install.sh | sh

#systemctl status ollama

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 7. Pull an LLM (IBM Granite 3.3 8B)"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"   
echo " "
ollama pull granite3.3:8b

echo " "
echo -e "${SUCCESS_COLOR}                                                        "

cat <<'EOF'

With everything installed, you can now run the LLM using
the following command to enter a chat promp session with the model:"

ollama run granite3.3:8b

Enjoy !

EOF

echo -e "${SUCCESS_COLOR}                                                        "
echo -e "${BANNER_RESET}"
echo " "




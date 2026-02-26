#!/bin/bash

#
# build-sovereign-ai-lab.sh
#
# This script is designed to set up a lab environment for running
# large language models (LLMs) using Ollama on an Ubuntu system. 
#
# 20210220 - 2300
#

INSTALL_COLOR="\e[0;104m\e[K"   # blue
SUCCESS_COLOR="\e[0;42m\e[K"   # green
BANNER_RESET="\e[0m"

install_apt_packages() {
	sudo apt install "$@" -y
}

detect_gpu_vendor() {
	local gpu_info
	gpu_info=$(lspci 2>/dev/null | grep -Ei 'VGA|3D|Display' || true)

	if echo "$gpu_info" | grep -qi 'NVIDIA'; then
		echo "nvidia"
	elif echo "$gpu_info" | grep -Eqi 'AMD|ATI'; then
		echo "amd"
	elif echo "$gpu_info" | grep -qi 'Intel'; then
		echo "intel"
	else
		echo "none"
	fi
}

is_nvidia_driver_installed() {
	command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1
}

is_amd_driver_installed() {
	lsmod | grep -q '^amdgpu'
}

is_intel_driver_installed() {
	lsmod | grep -q '^i915'
}

get_nvidia_utils_package() {
	local pkg

	for pkg in nvidia-utils-565-server nvidia-utils-565 nvidia-utils-550-server nvidia-utils-550; do
		if apt-cache show "$pkg" >/dev/null 2>&1; then
			echo "$pkg"
			return
		fi
	done

	pkg=$(apt-cache search '^nvidia-utils-[0-9]+' 2>/dev/null | awk '{print $1}' | grep -E '^nvidia-utils-[0-9]+(-server)?$' | sort -V | tail -n 1)
	if [ -n "$pkg" ]; then
		echo "$pkg"
	else
		echo "nvidia-utils"
	fi
}

install_gpu_drivers_if_missing() {
	local gpu_vendor
	gpu_vendor=$(detect_gpu_vendor)

	echo "Detected GPU vendor: $gpu_vendor"

	case "$gpu_vendor" in
		nvidia)
			if is_nvidia_driver_installed; then
				echo "NVIDIA driver already installed. Skipping driver installation."
			else
				echo "NVIDIA GPU detected and driver appears missing. Installing NVIDIA driver..."
				sudo ubuntu-drivers autoinstall
			fi
			;;
		amd)
			if is_amd_driver_installed; then
				echo "AMD driver already loaded. Skipping driver installation."
			else
				echo "AMD GPU detected and driver appears missing. Installing AMD GPU support packages..."
				install_apt_packages firmware-amd-graphics mesa-vulkan-drivers mesa-opencl-icd
			fi
			;;
		intel)
			if is_intel_driver_installed; then
				echo "Intel driver already loaded. Skipping driver installation."
			else
				echo "Intel GPU detected and driver appears missing. Installing Intel GPU support packages..."
				install_apt_packages intel-media-va-driver-non-free mesa-vulkan-drivers
			fi
			;;
		*)
			echo "No supported discrete GPU detected. Skipping GPU driver installation."
			;;
	esac
}

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} Build Sovereign AI Lab"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "

cat <<'EOF'

Given a fresh Ubuntu 24.04 install, this script sets up the Sovereign AI Lab
environment performing the following in order:

1. Update Repositories
2. Detect GPU and Install Drivers (if missing)
3. Install GPU Utilities
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
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 2. Detect GPU and Install Drivers (if missing)"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "
install_gpu_drivers_if_missing
gpu_vendor=$(detect_gpu_vendor)
echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 3. Install GPU Utilities"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "
if [ "$gpu_vendor" = "nvidia" ]; then
	nvidia_utils_package=$(get_nvidia_utils_package)
	echo "Installing NVIDIA utility package: ${nvidia_utils_package}"
	install_apt_packages "${nvidia_utils_package}" nvtop btop
else
	install_apt_packages nvtop btop
fi
echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 4. Install Build Utilities"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"
echo " "
install_apt_packages build-essential git gcc cmake curl

echo " "
echo -e "${INSTALL_COLOR}"
echo -e "${INSTALL_COLOR} 5. Install Python Environment and Development Utilities"
echo -e "${INSTALL_COLOR}"
echo -e "${BANNER_RESET}"   
echo " "
install_apt_packages python3-pip python3-venv python3-dev

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
the following command to enter a chat prompt session with the model:

ollama run granite3.3:8b

Enjoy !

EOF

echo -e "${SUCCESS_COLOR}                                                        "
echo -e "${BANNER_RESET}"
echo " "




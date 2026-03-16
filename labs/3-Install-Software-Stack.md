# Install Software Stack

In this exercise we will be installing the following software layers less the **model (LLM)** from
the software stack.

|        **Layer**       |             Example               |
|------------------------|-----------------------------------|
| Operating System (OS)  | Ubuntu 24.04 Desktop              |
| OS Utilities           | build-essential btop nvtop curl   |
| GPU Drivers/Utilities  | NVIDIA or AMD                     |
| Framework              | python3 and its libraries         |
| Inference/Engine       | [Ollama](https://ollama.com/)                |
| Model (LLM)            | [IBM Granite4:3b](https://ollama.com/library/granite4:3b)      |

### Install the Operating System
- **Start the server** and boot from media.
- **Installation Type:** Select **"Erase disk and install Ubuntu."**
- **Third-Party Software:** Ensure the box **"Install third-party software for graphics and Wi-Fi"** is checked. This helps Ubuntu detect the NVIDIA GPUs.
- **Help Improve Ubuntu:** Select **"No, don't share system data"** since we want to isolate this server.
- Reboot server

## Install Operating System Utilities
Log into the server to install OS utilities we will need

```bash
sudo apt update && sudo apt upgrade -y
sudo ubuntu-drivers autoinstall
sudo apt install build-essential git gcc cmake curl zstd nvtop btop -y
sudo apt install tcpdump net-tools ss iproute2 whois dnsutils -y
```

## Install Lab Tools
A set of bash and python scripts have been created to perform the labs. These are
included in the same Github repo as these lab exercises. They are released as open source and
readily inspectable on the [Git Repo](https://github.com/joecupano/sovereign-ai-lab) in the **code** directory before the next step which is to clone the repo onto the lab server and install the scripts in **/usr/local/bin** so they are in your path.

```bash
cd ~
git clone https://github.com/joecupano/sovereign-ai-lab.git
sudo cp ~/sovereign-ai-lab/code/* /usr/local/bin
```

## Install Software Stack 
If you wish to do a manual installation then go to **[Install Software Stack Manually](Advanced-Install-Software-Stack-Manually.md)** else continue to the next section.

## Install Software Stack (Automated)

```bash
build-bare-metal
```

If you know your hardware has a TPM module then your next lab is *[TPM Attestation](Advanced-TPM-Attestation.md)* else your next lab is *[Install LLM](4-Install-LLM.md)*
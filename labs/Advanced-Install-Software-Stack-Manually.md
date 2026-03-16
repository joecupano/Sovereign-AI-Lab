# Install Software Stack (Manual)

This lab walks through the steps performed by the automated install script in Lab 3, one command at a time. Use this if the automated script is not suitable for your hardware or environment.

### Install GPU Drivers and Utilities
Next step is to install software specific to your GPU:

For NVIDIA
```bash
sudo apt install nvidia-utils-565-server -y
sudo reboot
```

For AMD it is a little more involved
```bash
sudo apt update
sudo apt install wget gpg -y
wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.0/ jammy main" | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt update
sudo apt install fglrx-core rocm-hip-sdk -y
sudo usermod -aG video \$USER
sudo usermod -aG render \$USER
sudo reboot
```
Verify the GPU Hardware after reboot then run:

For NVIDIA
```bash
nvidia-smi
```

For AMD
```bash
roc-smi
```

You should see a table similar to the following displaying your GPU and its VRAM (NVIDIA example).

![nvidia-smi output](/pix/nvidia-smi-3050.png "nvidia-smi output")

### Install Inference/Model Server (Ollama)

Next, we install the Ollama engine. It will run as a system service and by default automatically detect your GPU and use it.

```bash
curl -fsSL https://ollama.com/install.sh \| sh
```

![Ollama install](/pix/ollama-install.png "Ollama install")

Once installed, we need to disable and mask the Ollama service to prevent it from starting automatically on boot

```bash
# Disable and mask the Ollama service to prevent it from starting automatically on boot
systemctl stop ollama > /dev/null 2>&1
systemctl disable ollama > /dev/null 2>&1
systemctl mask ollama > /dev/null 2>&1
```

If you know your hardware has a TPM module then your next lab is *[TPM Attestation](Advanced-TPM-Attestation.md)* else your next lab is *[Install LLM](4-Install-LLM.md)*
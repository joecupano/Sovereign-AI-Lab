# Build the Lab

Sovereign Ai requires knowing the chain of custody for your entire supply chain
**“from Dirt to Data”** begining where your **root of trust** begins. 

## Hardware
At the hardware level, full sovereignty is currently impossible. The AI semiconductor supply chain is globally concentrated and dominated by a small number of chokepoints: U.S.‑controlled chip design tools and architectures, ASML lithography equipment, Taiwanese fabrication (TSMC), and NVIDIA GPUs and software. No country can fully control this stack today. Sovereign AI strategies **must acknowledge and document these dependencies as accepted risks** rather than pretend they can be eliminated.

Where sovereignty becomes practical and defensible is **above the silicon layer.** Chain‑of‑custody across systems, logistics, data centers, networks, cloud environments, and software stacks is the primary control mechanism. This includes rigorous vendor qualification, bill‑of‑materials verification, tamper‑evident shipping, hardware and firmware attestation, controlled data‑center access, segmented and auditable networks, sovereign key management, and strict identity and access controls. 

Our **root of trust** begins with our hardware choices for the Lab. In a highly regulated environment systems, **not hardware** are accredited as compliant. The system used in the production of these labs is similar to one that can be accredited.

- Dell Precision 3620 with 64GB RAM
- 4TB PCIe Gen3 3D NAND NVMe M.2 SSD (Upgrade)
- 850W Power Supply, 80+ Gold Certified (Upgrade)
- 130W TDP CPU Cooler (Upgrade)
- NVIDIA RTX 3050 GPU

Since this is a student lab, your lab server hardware simply needs to meet following minimum specifications:

| Component         | Detail                         | 
|-------------------|--------------------------------|
| Processor         | Intel Core i7 series           |
| Memory            | 64GB RAM DDR4                  |
| GPU               | NVIDIA RTX 3050 GPU (6GB VRAM) |
|                   |     or AMD RX 7600 (8GB VRAM)  |
| Hard Drive        | 1 TB SSD                       |
| Network Interface | 1GB                            |

## Software
The layers of software to be installed in order include:

|        **Layer**       |             Example               |
|------------------------|-----------------------------------|
| Operating System (OS)  | Ubuntu 24.04 Desktop              |
| OS Utilities           | build-essential btop nvtop curl   |
| GPU Drivers            | NVIDIA or AMD                     |
| GPU Utilities          | nvidia-smi or roc-smi             |
| Python Environment     | python3 and its libraries         |
| Inference/Model Server | [Ollama](https://ollama.com/)                |
| Model Layer (LLM)      | [IBM Granite4:3b](https://ollama.com/library/granite4:3b)      |

### Install the Operating System
- **Create the Ubuntu 24.04 Desktop LTS install media.** Create either as a DVD (if your server has a DVD) or a bootable USB.
-- Supply Chain Note: Best to download the media from the [official Ubuntu site](https://ubuntu.com/download/desktop)
- **Start the server** and boot from media.
- **Installation Type:** Select **"Erase disk and install Ubuntu."**
- **Third-Party Software:** Ensure the box **"Install third-party software for graphics and Wi-Fi"** is checked. This helps Ubuntu detect the NVIDIA GPUs.
- **Help Improve Ubuntu:** Select **"No, don’t share system data"** since we want to isolate this server.
- Reboot server

## Install Operating System Utilities
Log into the server to install OS utilities we will need

```
sudo apt update && sudo apt upgrade -y
sudo ubuntu-drivers autoinstall
sudo apt install build-essential git gcc cmake curl nvtop btop -y
```

## Install Software Stack (Automated)
Next we will install the sofware stack for our AI platform

```
cd ~
git clone https://github.com/joecupano/sovereign-ai-lab
cd sovereign-ai-lab
```
You have two choices that this point, automated or manual installation of the
remainng software. If you wish automated, execute the following script.

```
./build_bare-metal.sh
```

If you wish to do a manual installation skip running the scripts and go
to the next section. Otherwise jump to the **Install LLM Model (IBM Granite)** section

## Install Software Stack (Manual) 
Trust but verify. Good for you in being adventurous.

### Install GPU Drivers and Utilities
Next step is to install software specific to your GPU:

For NVIDIA
```
sudo apt install nvidia-utils-565-server -y
sudo reboot
```

For AMD it is a little more involved
```
sudo apt update
sudo apt install wget gpg -y
wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key
sudo gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.0/ jammy main"
sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt update
sudo apt install fglrx-core rocm-hip-sdk -y
sudo usermod -aG video \$USER
sudo usermod -aG render \$USER
sudo reboot
```
Verify the GPU Hardware after reboot then run:

For NVIDIA
```
nvidia-smi
```

For AMD
```
roc-smi
```

You should see a table similar to the following displaying your GPU and its VRAM.

![nvidia-smi output](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_nvidiasmi-3050.png "nvidia-smi output")

### Install Python Environment
Next step is to install the Python environment:

```
sudo apt install python3-pip python3-venv python3-dev -y
```

### Install Inference/Model Server (Ollama)

Next, we install the Ollama engine. It will run as a system service and by default automatically detect your GPU and use it.

```
curl -fsSL https://ollama.com/install.sh \| sh
```

![Ollama install](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Install.png "Ollama install")

Once install run the following to verif ollama is running

```
systemctl status ollama
```

![Ollama status](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Status-exc.png "Ollama status")

It should say **"active (running).**

### Install LLM Model (IBM Granite)
Next, we download our first LLM. Given our focus on supply chain we will use **IBM Granite**.

IBM provides a "clear box" approach by disclosing its **full data provenance**. It recently earned a **95% score** on Stanford’s Foundation Model Transparency Index (FMTI) which is the highest ever recorded. Unlike **"black box"** models, IBM reveals the exact filtering, cleansing, and curation steps used to vet its 12+ trillion tokens for governance, risk, and bias.

Because IBM has such detailed documentation of its "Data Supply Chain," it offers uncapped intellectual property indemnity to its users. This proves that every piece of data was legally obtained, a rare feature in the AI industry that highlights the importance of ethical data sourcing.

We will be using Granite 3.0 8B Instruct**.** This "workhorse" model is optimized for the lab hardware specifications. It excels at structured tasks like RAG (Retrieval-Augmented Generation) and tool-calling, making it ideal to build reliable local AI applications.

With Ollama already running as a system service, we pull the IBM Granite 4 model.

```
ollama pull granite4:3b
```

![Ollama pull](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Pull.png "Ollama pull")


## Your first Chat session
With Ollama already running as a system service you can run your first chat session:

```
ollama run granite4:3b
```

![Ollama run](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Run.png "Ollama run")

At this point you can enter a chat query

![Ollama chat](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Chat.png "Ollama chat")

And/or perform **/?** For a list of commands.

![Ollama help](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Help.png "Ollama help")

We will exit the session with the command **/bye**

You are ready for the next lab.
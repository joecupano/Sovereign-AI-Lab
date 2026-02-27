# Lab 1 - Build the Lab

Sovereign Ai requires know the chain of custody for your entire supply chain
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

| **Processor**         | Intel Core i7 series           |
|-----------------------|--------------------------------|
| **Memory**            | 64GB RAM DDR4                  |
| **GPU**               | NVIDIA RTX 3050 GPU (6GB VRAM) |
|                       |     or AMD RX 7600 (8GB VRAM)  |
| **Hard Drive**        | 1 TB SSD                       |
| **Network Interface** | 1GB                            |


# Software
On top of the hardware, we will be installing layers of software that comprise the AI stack: This will include:

| Operating System   | Ubuntu 24.04 Desktop  |
| GPU drivers        | NVIDIA or AMD         |
| GPU utilities      | NVIDIA or AMD         |
| Runtime            | Python and Libraries  |
| LLM Orchestration  | [Ollama](https://ollama.com/                |
| LLM Model          | [IBM Granite4:3b](https://ollama.com/library/granite4:3b)      |

# Installing the Operating System (Ubuntu 24.04 Desktop)

- **Create the Ubuntu 24.04 Desktop LTS install media.** Create either as a DVD (if your server has a DVD) or a bootable USB.
-- Supply Chain Note: Best to download the media from the [official Ubuntu site](https://ubuntu.com/download/desktop)
- **Start the server** and boot from media.
- **Installation Type:** Select **"Erase disk and install Ubuntu."**
- **Third-Party Software:** Ensure the box **"Install third-party software for graphics and Wi-Fi"** is checked. This helps Ubuntu detect the NVIDIA GPUs.
- **Help Improve Ubuntu:** Select **"No, don’t share system data"** since we want to isolate this server.
- Reboot server

### Step 2: Drivers (NVIDIA)

Once Ubuntu is installed and you are logged in, open a **Terminal** (Ctrl+Alt+T) and perform the following:

1.  **Update Repositories, Install Drivers, and Build Utilities:**

```
sudo apt update && sudo apt upgrade -y
sudo ubuntu-drivers autoinstall
sudo apt install nvidia-utils-565-server nvtop btop -y
sudo apt install build-essential git gcc cmake curl -y
```

2.  **Install Python Environment and Development Utilities:**

```
sudo apt install python3-pip python3-venv python3-dev -y
sudo reboot
```

3.  **Verify the GPU Hardware:** After reboot then run:

```
nvidia-smi
```

You should see a table displaying your GPU and its VRAM.

![nvidia-smi output](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_nvidiasmi-3050.png "nvidia-smi output")

### Step 3: Engine (Ollama)

Next, we install the Ollama engine. It will run as a system service and by default automatically detect your GPU and use it.

1.  **Install Ollama:**

```
curl -fsSL https://ollama.com/install.sh \| sh
```

![Ollama install](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Install.png "Ollama install")


2.  **Verification:** Run the following:

```
systemctl status ollama
```

![Ollama status](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Status-exc.png "Ollama status")

It should say **"active (running).**

### Step 4: LLM (IBM Granite)

Next, we download our first LLM. Given our focus on supply chain we will use **IBM Granite**.

IBM provides a "clear box" approach by disclosing its **full data provenance**. It recently earned a **95% score** on Stanford’s Foundation Model Transparency Index (FMTI) which is the highest ever recorded. Unlike **"black box"** models, IBM reveals the exact filtering, cleansing, and curation steps used to vet its 12+ trillion tokens for governance, risk, and bias.

Because IBM has such detailed documentation of its "Data Supply Chain," it offers uncapped intellectual property indemnity to its users. This proves that every piece of data was legally obtained, a rare feature in the AI industry that highlights the importance of ethical data sourcing.

We will be using Granite 3.0 8B Instruct**.** This "workhorse" model is optimized for the lab hardware specifications. It excels at structured tasks like RAG (Retrieval-Augmented Generation) and tool-calling, making it ideal to build reliable local AI applications.

With Ollama already running as a system service, we next pull and run a model.

1.  **Pull the Model:**

```
ollama pull granite4:3b
```

![Ollama pull](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Pull.png "Ollama pull")

2.  **Run the Model:**

```
ollama run granite4:3b
```

![Ollama run](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Run.png "Ollama run")

At this point you can enter a chat query

![Ollama chat](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Chat.png "Ollama chat")

And/or perform **/?** For a list of commands.

![Ollama help](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab1_Ollama-Help.png "Ollama help")

We will exit the session with the command **/bye**

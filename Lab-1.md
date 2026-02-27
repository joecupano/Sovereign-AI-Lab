# Lab 1

## Lecture: “From Dirt to Data”

### Useful Background
*Where does AI physically come from? The physical origin of AI and the global semiconductor supply chain.*

- **The Periodic Table of AI:** Mining for minerals like Lithium, Cobalt, and Rare Earth elements needed for chips. Trace the minerals (Lithium, Cobalt, Silicon) from mines in the DRC and Chile to the "clean rooms" of Taiwan.
- **GPU vs CPU:** Understanding Semiconductors. Why is NVIDIA a household name? Why the **NVIDIA RTX 3050** is a "parallel processing beast" compared to a standard processor. Explain **CUDA cores** and **Tensor cores**.
- **The Global Factory and Geopolitics of Silicon:** The geography of the supply chain—from design in the US to manufacturing in Taiwan (TSMC) and assembly globally. Discuss why 90% of advanced chips come from one company (TSMC).
- **Activity:** Students map the journey of a single AI chip from a cobalt mine to a data center.

## Lab: Build the Lab

Your lab server hardware requires the following minimum specifications

| **Processor**         | Intel Core i7 series           |
|-----------------------|--------------------------------|
| **Memory**            | 64GB RAM DDR4                  |
| **GPU**               | NVIDIA RTX 3050 GPU (6GB VRAM) |
| **Hard Drive**        | 1 TB SSD                       |
| **Network Interface** | 1GB                            |

Given hardware, four layers that comprise the AI stack will be installed: OS, Driver, Engine, and Model.

### Step 1: OS Layer (Ubuntu 24.04)

1.  **Create the Ubuntu 24.04 Desktop LTS install media.** Create either as a DVD (if your server has a DVD) or a bootable USB.

    *Supply Chain Note: Best to download the media from the official Ubuntu site.*

2.  **Start the server** and boot from media.
3.  **Installation Type:** Select **"Erase disk and install Ubuntu."** As a matter of Supply Chain "wiping the disk" is the first step in ensuring data provenance and a clean environment.
4.  **Third-Party Software:** Ensure the box **"Install third-party software for graphics and Wi-Fi"** is checked. This helps Ubuntu detect the NVIDIA GPUs.
5.  **Help Improve Ubuntu:** Select **"No, don’t share system data"** since we want t isolate this server from externa influence.

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

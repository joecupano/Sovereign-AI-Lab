## Lab Platform Alternatives

The choice to use a bare-metal full standalone lab server was deliberate to readily demonstrate and measure a Sovereign AI solution with least amount of environment variables to contend with. For those comfortable with advanced administration of Windows 11 and Ubuntu, here are some other lab options you may consider

### Windows 11 and WSL 2

The hardware requirements remain the same in this configuration with Ubuntu 24.04 on WSL 2. The reason we do not use Ubuntu VM on Hyper-V is the “gymnastics” involved in supporting GPU-passthrough.

The gymnastics involve learning how to use Discrete Device Assignment (DDA) to pass an entire PCIe device into a virtual machine (VM) on standalone Hyper-V hosts with PowerShell. Doing so allows high performance access to devices like [NVMe storage](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/deploy/deploying-storage-devices-using-dda) or graphics cards from within a VM while being able to apply the device's native drivers. As with CPU stress testing, any GPU use seen is by the Windows desktop environment.

### Bare-Metal to Container use

Leveraging a containerized design versus a **bare-metal server** installation involves a strategic trade-off between **operational agility** and **system transparency**.

While the previous labs focused on bare-metal to give students "direct-to-silicon" visibility, the containerized approach is the industry standard for production-grade AI.

#### Strengths of Containerized Design (Agility)

- **Dependency Isolation:** In an air-gapped lab, "dependency hell" can be fatal. If a student accidentally updates a Python library that breaks the Ollama-NVIDIA handshake, a container allows you to simply delete the instance and restart from a clean, known-good image in seconds.
- **Portability across Workstations:** Once you build a "Master AI Image" on one server, you can export that container as a **tar file**. You can then physically move that file via USB to other air-gapped workstations, ensuring every student has an *identical* software environment.
- **Microservice Architecture:** Containers make it easy to run a "Web UI" in one container and "Ollama" in another. This mimics real-world enterprise architecture where the "Brain" and the "Interface" are separate services that talk to each other.
- **Simplified Model Lifecycle:** Open container artifacts can treat AI models like software versions. This makes it easier to track which version of LLM is being used for a specific audit.

#### Weaknesses of Containerized Design (Complexity)

- **The "Double-Driver" Problem: F**or a container to see your RTX 3050, you must maintain a perfect bridge. You need the NVIDIA Driver on the host *and* the NVIDIA Container Toolkit to pass that power through. If the host driver is updated but the toolkit isn't, the container loses its "brain."
- **Performance "Tax":** While modern runtimes have reduced this to a [negligible \~1% loss](), there is still a memory and latency overhead compared to bare-metal. On limited hardware like the 6GB RTX 3050, every bit of VRAM matters.
- **Abstracted Troubleshooting:** When something goes wrong on bare-metal, students use **systemctl**. In containers, they have to learn docker logs, docker exec, and volume mapping. This can distract from the "Open Science" curriculum by turning it into a "DevOps" course.
- **Security Blast Radius:** Recent vulnerabilities (like CVE-2024-0132) show that flaws in the NVIDIA Container Toolkit can allow an attacker to "escape" the container and take over the host. In an air-gapped lab, this risk is low, but it's a critical lesson in AI security.

### Comparison

| **Feature**             | **Bare-Metal (Current Lab)** | **Containerized**                 |
|-------------------------|------------------------------|-----------------------------------|
| **Setup Speed**         | Fast (One-line install)      | Moderate (Needs Docker + Toolkit) |
| **Hardware Visibility** | Direct & Transparent         | Abstracted via Driver Bridge      |
| **Reliability**         | High (Fewer moving parts)    | Very High (Easy to "Reset")       |
| **Industry Relevance**  | Research / Hobbyist          | Enterprise / Data Center          |

Staying with bare-metal for training is best deploying the entire stack automatically using a container could be a post Week 4 student challenge

### Example Container deployment model

The GitHub project **joecupano/airgap-lab-ai** is focused on Sovereign AI that has the following design principles:

- **Strict "Airgap" Focus:** The project provides a blueprint for running AI completely offline. Since your curriculum emphasizes the "physical layer" and "infrastructure layer," this project demonstrates how to decouple an AI solution from the global internet, reinforcing the concept of local sovereignty.
- **Compatibility with Ollama & Ubuntu:** The project is built around the **Ollama** engine and **Linux (Ubuntu/Debian)**, which are the same tools you’ve selected. It provides the scripts and configuration files needed to manage the local model library without needing an external API.
- **Hardware Efficiency:** The design is optimized for "Workstation-class" hardware rather than multi-million dollar clusters. It provides specific instructions on how to handle the memory constraints of an 6GB VRAM card (like your RTX 3050) when running 7B and 8B models like IBM Granite or OLMo.
- **Infrastructure**: Shows how "The Cloud" is not a requirement for AI. By following the project's networking configurations, students can see how to set up a private, local network where their workstations act as the "Data Center."
- **Software Stack:** Includes scripts for **Model Management**. Students can see how to "sideload" model files (GGUF format) that they might have downloaded on a secure machine and moved to the air-gapped lab via a verified USB drive.
- **Ethics & Privacy:** Solid proof of concept for **Data Privacy**. You can demonstrate that no prompt or data ever leaves the room, which is a major requirement for industries like healthcare, defense, and high-level legal work.
- **Systemd services** ensure Ollama starts automatically on boot in an offline state.
- **Validation scripts** to check if the NVIDIA drivers are properly communicating with the model without trying to "call home" for updates.
- **A "Clean Environment" checklist** which mirrors a professional supply chain audit.

### AMD GPU

In the current market (February 2026), the AMD equivalent to the **NVIDIA RTX 3050** is the **AMD Radeon RX 9060 XT**.

While both cards are marketed as mid-range leaders for around \$300, they represent two very different approaches in AI hardware. Here is how they stack up for your lab.

| **Feature**      | **NVIDIA RTX 3050**            | **AMD Radeon RX 9060 XT**      |
|------------------|--------------------------------|--------------------------------|
| **Architecture** | Blackwell (5nm)                | RDNA 4 (4nm)                   |
| **VRAM**         | 6 GB GDDR7                     | 16 GB GDDR6                    |
| **AI Software**  | CUDA (Industry Standard)       | ROCm (Open Source)             |
| **Raw AI Speed** | Higher (Tensor Core advantage) | Moderate (Higher raw TFLOPS)   |
| **Best For**     | "Plug-and-play" AI/Research    | Large Models & Open Ecosystems |

While the NVIDIA RTX 3050 might struggle with 8B or 14B models, the AMD RX 9060 XT can load much larger models (or more context) entirely onto the card without "spilling" into slow system RAM. But setup for is more difficult for AMD. To get Ollama working with AMD, you must install the **ROCm** (Radeon Open Compute) stack. While ROCm 6.x has improved significantly in 2026, it still lacks the "it just works" feel of NVIDIA's CUDA. Most AI tools on GitHub are written for NVIDIA first.

If you choose the AMD equivalent, your **Week 1 "Installation"** would change to:

1. **Add the AMD repository**
```
sudo apt update
sudo apt install wget gpg -y
wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key
sudo gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.0/ jammy main"
sudo tee /etc/apt/sources.list.d/rocm.list
```

2. **Install the Driver and ROCm**
```
sudo apt update
sudo apt install fglrx-core rocm-hip-sdk -y
```

3. **Add permissions**
```
sudo usermod -aG video \$USER
sudo usermod -aG render \$USER
```

4. **Reboot the Server.**

Instead of nvidia-smi, AMD uses a tool called **roc-smi**. that produces similar data.

# Lab Foundation 

We start the lab exercises by grouding ourselves in three areas:
- What is the Sovereign Cloud Architecture we are building
- What legal jurisdiction and data privacy law our lab is subject to
- Where does our root of trust begin in our supply chain

## Sovereign Cloud Architecture
Sovereign AI is built upon a Sovereign Cloud. The guide covered various cloud architectures. Since this lab will be built in your facility where you have hands-on the physical infrastructure we will consider it on an **on-premise private cloud**.

*On-premise Private Cloud means the organization owns the hardware, operates it
in their own data center, and runs a cloud management platform on top of it.
Common platforms include VMware vSphere/vSAN, OpenStack, Nutanix, and
Red Hat OpenShift for container-centric workloads. The organization controls
everything from the physical layer up.*

Your lab hardware should be installed on its own network segment so you can monitor
network traffic with an inline device such as a firewall or router. These labs were 
tested with hardware on it's own segment connected to a [pfSense firewall](https://www.pfsense.org/getting-started/) which in turn connects to the Internet. The firewall not only controls network traffic but can be used to monitor traffic specifically to/from the lab.

## Legal Jurisdiction and Data Privacy Law

**Exercise**
Referencing the guide, record the **legal jurisdiction** and **data privacy** laws your **on-premise private cloud** is subject to.

## Supply Chain Root of Trust
### Hardware
We go in depth on this topic in the Guide including the importance of demonstrating a complete chain of custody. In that discussion we said when it comes to hardware **full sovereignty is currently impossible and where your root of trust begins**. And so our root of trust will begin here. But what we can do is **trust but verify** by searching for trusted hardware attestations at the systems level in our lab build.

### System
As an example, these labs were tested with the following system:

- Dell Precision 3620 with 64GB RAM
- NVIDIA RTX 3050 GPU
- Crucial 4TB PCIe Gen3 3D NAND NVMe M.2 SSD (Upgrade)
- ARESGAME 850W Power Supply, 80+ Gold Certified (Upgrade)
- 130W TDP CPU Cooler (Upgrade)

Dell Technologies publishes their [supply chain security](https://www.delltechnologies.com/asset/en-us/services/support/legal-pricing/dell-services-supply-chain-security.pdf) with the **Dell Precision T3620** chosen in building/testing these labs.

Supply chain security and other compliance information for the **NVIDIA RTX 3050** GPU used was availabel from their [NVIDIA AI Trust Center](https://www.nvidia.com/en-us/ai-trust-center/security-compliance/) site.

Micron and its consumer brand, Crucial, handle supply chain security through a combination of manufacturing certifications, "Security by Design" engineering, and standardized hardware attestation protocols.

Micron and its consumer brand, Crucial, handle supply chain security through a combination of manufacturing certifications, "Security by Design" engineering, and standardized hardware attestation protocols. As a primary manufacturer of silicon (unlike "rebranders" or budget vendors), Micron controls a much larger portion of their supply chain—from the fabrication of the memory chips to the final assembly of the RAM or SSD. Information on their supply chain security was available on the [Micron Customer Trust Certer](https://www.micron.com/about/company/customer-trust-center) site.

The power supply (PSU) and cooling needed be upgraded to meet the needs of the GPU. 
Because PSU are primarily passive or "dumb" hardware (analog power delivery rather than intelligent silicon with complex firmware) their supply chain security is handled through standard manufacturing certifications rather attestations. This was deemed as acceptable risk. The UPS the workstation is plugged into would block any kind of signalling if the PSU was compromised with some "smart" system that would use the AC line as a communication lonk.

#### Your Lab System
Your lab server hardware needs to meet following minimum specifications:

| Component         | Detail                         | 
|-------------------|--------------------------------|
| Processor         | Intel Core i7 series           |
| Memory            | 64GB RAM DDR4                  |
| GPU               | NVIDIA RTX 3050 GPU (6GB VRAM) |
|                   |     or AMD RX 7600 (8GB VRAM)  |
| Hard Drive        | 1 TB SSD                       |
| Network Interface | 1GB                            |

**Exercise**
Find supply chain security attestations for all system components used in your lab.

### Software
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

Canonical, the company behind Ubuntu, manages supply chain security through a combination of cryptographic integrity, software bill of materials (SBOM), and international security certifications.

Because Ubuntu is a software distribution, its "supply chain" involves the thousands of open-source packages that are compiled into the OS for which the source code is published. Complete details can be found on the [Ubuntu Security Assurance](https://ubuntu.com/security/assurances) site.

**Exercise**
- What is the supply chain security for each of the remaining layers.
- Which layers (if layer) the transparency is lacking and you need to accept the risk

You are ready for the next lab.
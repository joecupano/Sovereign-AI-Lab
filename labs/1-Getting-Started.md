# Getting Started

# Hardware

In **[the Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)** we acknowledge full sovereignty is currently impossible at the hardware level. We **trust but verify** through **attestations** published by the vendors in **accepting risk** rather than pretend they can be eliminated. Our **root of trust** begins with hardware choices for the Lab.

In creating and testing the lab exercises the hardware chosen has attestations and a history used in building trusted systems for highly regulated environments. It included:

- Dell Precision 3620 with 64GB RAM
- NVIDIA RTX 3050 GPU
- Crucial 4TB PCIe Gen3 3D NAND NVMe M.2 SSD (Upgrade)
- ARESGAME 850W Power Supply, 80+ Gold Certified (Upgrade)
- 130W TDP CPU Cooler (Upgrade)

Dell Technologies publishes their [supply chain security](https://www.delltechnologies.com/asset/en-us/services/support/legal-pricing/dell-services-supply-chain-security.pdf) with the **Dell Precision T3620** chosen in building/testing these labs.

Supply chain security and other compliance information for the **NVIDIA RTX 3050** GPU used was available from their [NVIDIA AI Trust Center](https://www.nvidia.com/en-us/ai-trust-center/security-compliance/) site.

Micron and its consumer brand, Crucial, handle supply chain security through a combination of manufacturing certifications, "Security by Design" engineering, and standardized hardware attestation protocols. As a primary manufacturer of silicon (unlike "rebranders" or budget vendors), Micron controls a much larger portion of their supply chain, from the fabrication of the memory chips to the final assembly of the RAM or SSD. Information on their supply chain security was available on the [Micron Customer Trust Center](https://www.micron.com/about/company/customer-trust-center) site.

The power supply (PSU) and cooling needed to be upgraded to meet the needs of the GPU.
Because PSUs are primarily passive or "dumb" hardware (analog power delivery rather than intelligent silicon with complex firmware), their supply chain security is handled through standard manufacturing certifications rather than attestations. This was deemed an acceptable risk. The UPS the workstation is plugged into would block any kind of signaling if the PSU was compromised with some "smart" system that would use the AC line as a communication link.

You do not need to build this exact system, the minimum specifications need to be as follows:

| Component         | Detail                          | 
|-------------------|---------------------------------|
| Processor         | Intel Core i7 series            |
| Memory            | 64GB RAM DDR4                   |
| GPU               | NVIDIA RTX 3050 GPU (6GB+ VRAM) |
|                   |     or AMD RX 7600 (8GB VRAM)   |
| Hard Drive        | 1 TB SSD                        |
| Network Interface | 1GB                             |

# Architecture

## Simple Lab Architecture

![Simple Lab](/pix/Trusted-Lab_SIMPLE.png "Simple Lab")

In context to **[the Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)** our lab will be considered part of an **on-premise private cloud** deployment. This means you follow the **data privacy and jurisdiction laws** your
lab is physically located in. You will also want to isolate your lab environment from the
rest of the networks in your "private cloud" using a consumer router switch between your ISP provided router and your internal and lab network. Doing this is not only a best cybersecurity 
practice but also isolates all lab network traffic to simplify monitoring for lab exercises
by having less noise on the wire to filter through.

## Advanced Lab Architecture

![Advanced Lab Setup](/pix/Trusted-Lab_ADVANCED.png "Advanced Lab Setup")

This is the same network architecture used in the production of the lab exercises. The ISP provided router is considered untrusted including any services and wireless network it provides. The [pfSense firewall](https://www.pfsense.org/getting-started/) provides all services (DHCP, DNS, etc) required by the internal, lab, DMZ and our own trusted wireless network. Each network is attached to one of the four network ports on the firewall. The Wireless AP is a bridge directly connected to one of the firewall network ports.

### Network Details

ISP DEVICE
- Often includes five port switch and wireless bridge on same network.
- Configured as NAT outbound only by default
- Permits 192.168.1.0/24 to the Internet
- Only use included wireless as Guest Wireless network to Internet only

SWITCHES
- Physical switch for each network. NO VLAN USE FOR SEPARATE NETWORKS

FIREWALL
- Pfsense on Intel i5 Quad Core 8GB RAM with Intel Quad NIC
- Blocks Internet originated connections by default 
- Permits Internet originated connections to specific DMZ devices
- Permits Internal, Lab, Wireless and DMZ originated connections to the Internet
- Permits Internal originated connections to Lab, 
- Blocks Lab originated connections to Internal

WIRELESS
- Wireless AP, not a Wireless Router. Used commercial equipment preferred with IDS/IDP capability
- Direct connect to FIREWALL dedicated port. FIREWALL serves up DHCP to clients on Wireless

DMZ
- Only configured to accept Internet originated connections

INTERNAL
 Port-level security optionally implemented on internal network switch

## Legal Jurisdiction and Data Privacy Law

**Exercise**
- Referencing the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf), record the **legal jurisdiction** and **data privacy** laws your **on-premise private cloud** is subject to.
- Find supply chain security attestations for all system components used in your lab.

# Software Stack
We will build the software stack with the following layers:

|        **Layer**       |             Example               |
|------------------------|-----------------------------------|
| Operating System (OS)  | Ubuntu 24.04 Desktop              |
| OS Utilities           | build-essential btop nvtop curl   |
| GPU Drivers/Utilities  | NVIDIA or AMD                     |
| Framework              | python3 and its libraries         |
| Inference/Engine       | [Ollama](https://ollama.com/)                |
| Model (LLM)            | [IBM Granite4:3b](https://ollama.com/library/granite4:3b)      |

Canonical, the company behind Ubuntu, manages supply chain security through a combination of cryptographic integrity, software bill of materials (SBOM), and international security certifications.

Because Ubuntu is a software distribution, its "supply chain" involves the thousands of open-source packages that are compiled into the OS for which the source code is published. Complete details can be found on the [Ubuntu Security Assurance](https://ubuntu.com/security/assurances) site.

[NVIDIA](https://docs.nvidia.com/attestation/index.html) and [AMD](https://www.amd.com/en/products/processors/server/epyc/confidential-computing.html) provide their own attestations as linked.

The Framework and Inference/Engine are all Open Source and can be inspected. 

## Model (LLM)

In the world of AI, there is a distinct difference between **Open Weights** (where you get the model but don't know how it was made) and **Open Science** (where every step of the process is documented).

For a curriculum focused on the "AI Stack and Supply Chain," you want models that provide a paper trail for their data and training. 

IBM Granite bridges the gap between **Open Science** (academic rigor) and **Enterprise Transparency** (business accountability). As of late 2025, it holds the record for the highest score on Stanford's Foundation Model Transparency Index.

- **Why it's transparent:** IBM provides a "clear box" approach by disclosing its **full data provenance**. It recently earned a **95% score** on Stanford's Foundation Model Transparency Index (FMTI), the highest ever recorded. Unlike "black box" models, IBM reveals the exact filtering, cleansing, and curation steps used to vet its 12+ trillion tokens for governance, risk, and bias.
- **Key Detail:** **Legal & Ethical Indemnity.** Because IBM has such detailed documentation of its "Data Supply Chain," it offers uncapped intellectual property indemnity to its users. This proves that every piece of data was legally obtained, a rare feature in the AI industry that highlights the importance of ethical data sourcing.
- **Model to use:** Granite 4.3b Instruct. This "workhorse" model is optimized for your lab hardware. It excels at structured tasks like RAG (Retrieval-Augmented Generation) and tool-calling, making it ideal for students to build reliable local AI applications.

**Exercise**
- Document the chain of custody for the hardware and software layers.
- Which layers lack transparency and require you to accept the risk?

*Optional: For a deeper comparison of sovereign-friendly LLMs and their transparency levels, see [LLM Transparency](Advanced-LLM-Transparency.md).*

*Next Lab: [Create OS Install Media](2-Create-OS-Install-Media.md)*

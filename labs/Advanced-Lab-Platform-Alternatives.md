# Lab Platform Alternatives

A bare-metal lab server was chosen to readily demonstrate and measure a Sovereign AI solution with the least number of variables to contend with. For those comfortable with advanced administration of Windows 11 and Ubuntu, here are some other lab options you may consider.

### Windows 11 and WSL 2

The hardware requirements remain the same in this configuration with Ubuntu 24.04 on WSL 2. The reason we do not use Ubuntu VM on Hyper-V is the "gymnastics" involved in supporting GPU passthrough.

The gymnastics involve learning how to use Discrete Device Assignment (DDA) to pass an entire PCIe device into a virtual machine (VM) on standalone Hyper-V hosts with PowerShell. Doing so allows high-performance access to devices like [NVMe storage](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/deploy/deploying-storage-devices-using-dda) or graphics cards from within a VM while being able to apply the device's native drivers.

WSL 2 takes a different approach: it uses a paravirtualized GPU driver model where the NVIDIA driver is installed on Windows and WSL 2 accesses the GPU through a translation layer. This means students do NOT install NVIDIA drivers inside WSL 2; only the CUDA toolkit is installed inside the Linux environment. The Windows NVIDIA driver handles the hardware directly.

The Linux kernel for WSL 2 is compiled without TPM support, which means the [Advanced TPM Attestation](Advanced-TPM-Attestation.md) lab cannot be performed in this environment.

#### Differences from Bare Metal by Lab

The following differences will manifest when running the labs in WSL 2 versus bare metal.

**Lab 2: Create OS Install Media**
All GPG and SHA-256 verification commands (`gpg`, `sha256sum`) work identically in WSL 2. However, writing the verified ISO to a USB drive from within WSL 2 requires [usbipd-win](https://github.com/dorssel/usbipd-win) to attach the USB device to the WSL 2 environment. Without it, USB drives connected to Windows are not visible inside WSL 2. The simpler approach is to perform the verification inside WSL 2 and write the USB using a Windows tool such as [Rufus](https://rufus.ie/en/) or [balenaEtcher](https://etcher.balena.io/).

**Lab 3: Install Software Stack**
The automated install script may attempt to install NVIDIA drivers for Linux. In WSL 2 this step must be skipped: the Windows host already provides the GPU driver. Install only the CUDA toolkit inside WSL 2 and verify GPU visibility with `nvidia-smi` inside WSL 2 after the toolkit is installed. Thus you need to choose the [Install the Software Stack (Manually)](Advanced-Install-Software-Stack-Manually.md) lab.

**Lab 5: Assess the Lab**
This is the lab where WSL 2 differences are most significant for sovereignty assessment.

- **Network interface:** WSL 2 uses a virtual network adapter (Hyper-V NAT) with its own subnet, separate from the Windows host's physical NIC. `tcpdump` inside WSL 2 captures only traffic originating from the WSL 2 environment, not from the Windows host. A student verifying that no Ollama traffic leaves the machine will only see WSL 2-generated traffic; any Windows-side network activity is invisible.
- **iptables:** WSL 2 uses a modified kernel with limited netfilter support. iptables egress rules applied inside WSL 2 constrain only WSL 2 traffic. They do not restrict what Windows itself sends over the network. This is a genuine sovereignty gap: the AI inference is isolated inside WSL 2, but the host OS remains outside the student's control.
- **Ollama binding:** Ollama binds to `127.0.0.1:11434` inside WSL 2 by default, which is correct for local inference. Windows 11 automatically forwards WSL 2 localhost ports to the Windows host, so accessing Ollama from a Windows browser at `localhost:11434` typically works without additional configuration.
- **systemd:** WSL 2 supports systemd on Windows 11 22H2 and later, but it must be explicitly enabled by adding `systemd=true` under `[boot]` in `/etc/wsl.conf` and restarting the WSL 2 instance. Without this, `systemctl` commands will fail. Verify systemd is active with `systemctl --version` before running any lab exercise that uses systemctl.

**Lab 6: CPU vs GPU**
GPU inference works in WSL 2 via the CUDA translation layer and performance is close to bare metal for CUDA workloads. GPU utilization reported by `nvidia-smi` inside WSL 2 reflects the WDDM translation layer and may show slightly different utilization percentages than bare metal. The Windows desktop environment also consumes GPU resources continuously; students should account for this when recording their idle baseline.

**Lab 7: Power Consumption**
The Kill-A-Watt measures physical power at the wall regardless of the software layer, so power readings remain valid. GPU utilization percentages captured via `nvidia-smi` inside WSL 2 will include overhead from the Windows display driver. Note the Windows desktop processes consuming GPU resources before running the Ollama benchmarks and treat the idle baseline accordingly.

**Advanced TPM Attestation**
Not available. The WSL 2 kernel is compiled without TPM support. This lab requires bare metal.

### Container Use
Leveraging a containerized design versus a **bare-metal server** installation involves a strategic trade-off between **operational agility** and **system transparency**. While the labs focused on bare-metal to give students "direct-to-silicon" visibility, the containerized approach is the industry standard for production-grade AI.

#### Strengths of Containerized Design (Agility)

- **Dependency Isolation:** In an air-gapped lab, "dependency hell" can be fatal. If a student accidentally updates a Python library that breaks the Ollama-NVIDIA handshake, a container allows you to simply delete the instance and restart from a clean, known-good image in seconds.
- **Portability across Workstations:** Once you build a "Master AI Image" on one server, you can export that container as a **tar file**. You can then physically move that file via USB to other air-gapped workstations, ensuring every student has an *identical* software environment.
- **Microservice Architecture:** Containers make it easy to run a "Web UI" in one container and "Ollama" in another. This mimics real-world enterprise architecture where the "Brain" and the "Interface" are separate services that talk to each other.
- **Simplified Model Lifecycle:** Container tooling can version AI models like software packages. This makes it easier to track which version of the LLM is in use for a given audit.

#### Weaknesses of Containerized Design (Complexity)

- **The "Double-Driver" Problem:** For a container to see your RTX 3050, you must maintain a perfect bridge. You need the NVIDIA Driver on the host *and* the NVIDIA Container Toolkit to pass that power through. If the host driver is updated but the toolkit isn't, the container loses its "brain."
- **Performance "Tax":** While modern runtimes have reduced this to a negligible ~1% loss, there is still a memory and latency overhead compared to bare-metal. On limited hardware like the 6GB RTX 3050, every bit of VRAM matters.
- **Abstracted Troubleshooting:** When something goes wrong on bare-metal, students use **systemctl**. In containers, they have to learn docker logs, docker exec, and volume mapping. This can distract from the "Open Science" curriculum by turning it into a "DevOps" course.
- **Security Blast Radius:** Recent vulnerabilities (like CVE-2024-0132) show that flaws in the NVIDIA Container Toolkit can allow an attacker to "escape" the container and take over the host. In an air-gapped lab, this risk is low, but it's a critical lesson in AI security.

#### Comparison

| **Feature**             | **Bare-Metal (Current Lab)** | **Containerized**                 |
|-------------------------|------------------------------|-----------------------------------|
| **Setup Speed**         | Fast (One-line install)      | Moderate (Needs Docker + Toolkit) |
| **Hardware Visibility** | Direct & Transparent         | Abstracted via Driver Bridge      |
| **Reliability**         | High (Fewer moving parts)    | Very High (Easy to "Reset")       |
| **Industry Relevance**  | Research / Hobbyist          | Enterprise / Data Center          |

Staying with bare-metal for training is best. Deploying the entire stack automatically using containers is a good advanced student challenge after the core labs are complete.
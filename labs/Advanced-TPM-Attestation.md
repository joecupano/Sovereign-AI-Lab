# TPM Hardware Attestation

This exercise puts hands on the hardware root of trust the Trusted Platform Module (TPM) that the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) identifies as the foundation of chain-of-custody verification at the systems layer:

> *"Modern server platforms support hardware-based attestation through standards like the Trusted Platform Module (TPM) and TCG DICE. These allow you to cryptographically verify that the hardware and firmware configuration matches a known-good state established at the factory. This is arguably the most technically rigorous form of chain-of-custody verification available today."*

TPM attestation answers one of the six chain-of-custody questions the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) requires you to be able to answer with evidence:

> *"Was it tampered with or modified between manufacture and deployment?"*

By the end of this exercise you will have read your TPM's identity, captured its Platform Configuration Register (PCR) baseline measurements, and understood what a tampered firmware state would cause to change turning an abstract concept in the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) into observable data on your own hardware.

## Prerequisites

- [Install Software Stack](Install-Software-Stack.md)
- TPM 2.0 chip present (verify below)

## Step 1: Verify TPM Presence

```bash
# Check if kernel sees a TPM
ls /dev/tpm* 2>/dev/null && echo "TPM device found" || echo "No TPM device found"
```

If you get "No TPM device found" then there is no TPM. You are done with this lab and can proceed
to [Install LLM](Install-LLM.md)

```
# Check TPM version and capabilities
cat /sys/class/tpm/tpm0/tpm_version_major 2>/dev/null || echo "TPM sysfs not available"

# Check via ACPI
sudo dmesg | grep -i tpm | head -20

# Check via systemd
sudo systemctl status tpm2-abrmd 2>/dev/null | head -10
```

### Platform-Specific BIOS Verification

Before the OS boots, confirm the TPM is enabled in firmware. Each manufacturer places this differently:

#### Dell Precision / OptiPlex / Latitude

1. Boot and press **F2** at the Dell splash screen to enter BIOS Setup
2. Navigate to: **Security** then to **TPM Security**
3. Confirm:
   - **TPM Security**: Enabled
   - **TPM Status**: Owned or Activated
   - **TPM Version**: 2.0
   - **TPM PPI Bypass Command**: note the setting
4. Note the **TPM firmware version** shown record this for your lab report

**Dell-specific command to query TPM from OS:**
```bash
# Dell systems often expose TPM info via smbios
sudo dmidecode -t 43 2>/dev/null || sudo dmidecode | grep -A5 "TPM"
```

#### HP EliteDesk / ProDesk / Z-Series Workstation

1. Boot and press **F10** at the HP logo to enter BIOS Setup (UEFI/BIOS Setup Utility)
2. Navigate to: **Security TPM Embedded Security**
3. Confirm:
   - **TPM Device**: Available
   - **TPM State**: Enabled
   - **Clear TPM**: Do NOT select this
4. Note the TPM specification version

**HP-specific command:**
```bash
# HP systems check HP-specific BIOS data
sudo dmidecode -t 1 | grep -E "Manufacturer|Product|Version"
sudo dmidecode | grep -A10 "TPM\|Trusted"
```

#### Lenovo ThinkStation / ThinkCentre / ThinkPad

1. Boot and press **F1** (ThinkPad) or **F1/Enter then F1** (ThinkCentre/ThinkStation) to enter BIOS
2. Navigate to: **Security Security Chip**
3. Confirm:
   - **Security Chip**: Active
   - **Security Chip Type**: TPM 2.0
   - **Security Chip Selection**: Discrete TPM (preferred) or Firmware TPM
4. Note whether you have a **discrete TPM** (physical chip, higher assurance) or **fTPM** (firmware-based, lower assurance). This distinction matters for sovereign deployments.

**Lenovo-specific command:**
```bash
# Lenovo systems
sudo dmidecode -t 1 | grep -E "Manufacturer|Product|Version"
# Check for Lenovo TPM-specific entries
sudo dmidecode | grep -A5 -i "security chip\|tpm"
```

> **Sovereign AI Note:** Discrete TPM chips provide a separate hardware security boundary independent of the main CPU firmware. Firmware TPMs (fTPM/PTT) run within the CPU's firmware environment and are more common and adequate for many use cases, but discrete TPMs provide stronger isolation. The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s reference to TPM is agnostic to implementation type; your lab report should document which type your platform uses and what that means for your sovereignty posture.

---

## Step 2: Install TPM Tools

```bash
sudo apt update
sudo apt install -y tpm2-tools tpm2-abrmd

# Start the TPM access broker if not running
sudo systemctl enable tpm2-abrmd
sudo systemctl start tpm2-abrmd
sudo systemctl status tpm2-abrmd
```

Verify tools are working:

```bash
tpm2_getcap -l 2>/dev/null | head -20
```

---

## Step 3: Read the TPM Identity

The TPM has a unique, factory-provisioned identity called the **Endorsement Key (EK)**. This is the hardware's cryptographic identity equivalent to a serial number that cannot be forged.

```bash
# Read the TPM's endorsement key certificate (if provisioned by manufacturer)
tpm2_getekcertificate -o ~/tpm-ek-cert.der 2>/dev/null && \
  echo "EK certificate retrieved" || \
  echo "No EK certificate (manufacturer may not have provisioned one)"

# Read TPM manufacturer info
tpm2_getcap properties-fixed 2>/dev/null | grep -E "TPM2_PT_MANUFACTURER|TPM2_PT_FIRMWARE|TPM2_PT_VENDOR"
```

Decode the manufacturer code:

```bash
# Common manufacturer codes
# 414D4400 = AMD
# 49465800 = Infineon (common in Dell/Lenovo discrete TPMs)
# 4E544300 = NTC (Nuvoton, common in HP)
# 53544D20 = STMicroelectronics
# 4D534654 = Microsoft (fTPM)
# 494E5443 = Intel (PTT/fTPM)

tpm2_getcap properties-fixed 2>/dev/null | grep "TPM2_PT_MANUFACTURER" | \
  awk '{print $NF}' | \
  python3 -c "import sys; val=sys.stdin.read().strip(); \
  b=bytes.fromhex(val[2:] if val.startswith('0x') else val); \
  print('TPM Manufacturer:', b.decode('ascii', errors='replace'))"
```

Record in your lab report:
- TPM manufacturer
- Firmware version
- Whether an EK certificate was provisioned

---

## Step 4: Capture PCR Baseline Measurements

Platform Configuration Registers (PCRs) are the heart of TPM attestation. Each PCR accumulates cryptographic measurements of what was loaded during the boot sequence. They cannot be reset without a full system reboot making them tamper-evident.

```bash
# Read all PCR values (SHA-256 bank)
tpm2_pcrread sha256 > ~/tpm-pcr-baseline.txt
cat ~/tpm-pcr-baseline.txt
```

**Understanding the PCR layout:**

| PCR |                Measures             |
|-----|-------------------------------------|
|  0  | BIOS/UEFI firmware code             |
|  1  | BIOS/UEFI configuration and data    |
|  2  | Option ROM code                     |
|  3  | Option ROM data                     |
|  4  | Boot Manager code (GRUB/bootloader) |
|  5  | Boot Manager configuration          |
|  6  | State transitions and wake events   |
|  7  | Secure Boot state and certificates  |
|  8  | OS and application measurements     |

For sovereign AI purposes, **PCRs 0, 1, and 7 are the most critical** they represent the firmware integrity and Secure Boot state. If these values change between reboots without a legitimate firmware update, something tampered with your hardware.

```bash
# Read specifically the sovereignty-critical PCRs
echo "=== Firmware Integrity PCRs ===" > ~/tpm-sovereign-pcrs.txt
tpm2_pcrread sha256:0,1,7 >> ~/tpm-sovereign-pcrs.txt
cat ~/tpm-sovereign-pcrs.txt
```

---

## Step 5: Verify Secure Boot State

Secure Boot is the UEFI-layer chain of trust that TPM PCR7 measures. Verify it is active:

```bash
# Check Secure Boot status
mokutil --sb-state 2>/dev/null || echo "mokutil not installed install with: sudo apt install mokutil"

# Check via kernel
cat /sys/firmware/efi/efivars/SecureBoot-* 2>/dev/null | xxd | head -5

# Alternative check
dmesg | grep -i "secure boot" | head -5
```

For sovereign deployments, Secure Boot must be enabled. A disabled Secure Boot means PCR7 will not reflect the trusted boot state, undermining the attestation chain.

---

## Step 6: Create a Signed Baseline Your Chain-of-Custody Record

This step creates the documented evidence artifact that the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s chain-of-custody evidence package requires.

```bash
# Combine all TPM identity and measurement data into a signed baseline record
cat > ~/tpm-attestation-record.txt << EOF
=== TPM ATTESTATION BASELINE RECORD ===
Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Hostname: $(hostname)
Platform: $(sudo dmidecode -t 1 | grep -E "Manufacturer|Product" | tr '\n' ' ')
Kernel: $(uname -r)
Ubuntu Version: $(lsb_release -d | cut -f2)

=== TPM PROPERTIES ===
$(tpm2_getcap properties-fixed 2>/dev/null | grep -E "TPM2_PT_MANUFACTURER|TPM2_PT_FIRMWARE|TPM2_PT_VENDOR|TPM2_PT_SPEC")

=== SECURE BOOT STATE ===
$(mokutil --sb-state 2>/dev/null || dmesg | grep -i "secure boot" | head -3)

=== PCR SHA-256 BASELINE ===
$(tpm2_pcrread sha256 2>/dev/null)

=== RECORD HASH ===
EOF

# Hash the record itself to create a tamper-evident baseline
sha256sum ~/tpm-attestation-record.txt | tee -a ~/tpm-attestation-record.txt

echo "Attestation record created: ~/tpm-attestation-record.txt"
cat ~/tpm-attestation-record.txt
```

Store this file securely. In a production sovereign deployment this record would be:
- Signed with a key held in a sovereign HSM
- Stored in an immutable audit log
- Re-verified after every planned firmware update
- Compared against at every boot as part of remote attestation

---

## Step 7: Simulate a Detection Scenario

Reboot the system, then re-read the PCRs and compare. In a normal environment with no firmware changes, PCRs 0, 1, and 7 should be identical.

```bash
# After reboot, run this comparison
tpm2_pcrread sha256:0,1,7 > ~/tpm-pcr-post-reboot.txt

# Compare against baseline
diff ~/tpm-sovereign-pcrs.txt ~/tpm-pcr-post-reboot.txt && \
  echo "PCR MATCH firmware integrity confirmed" || \
  echo "PCR MISMATCH investigate before proceeding"
```

**If PCRs differ unexpectedly:**
- Was a BIOS/UEFI update applied?
- Was a hardware component changed?
- Was Secure Boot configuration modified?

In a production sovereign deployment, a PCR mismatch would trigger a hold on the system pending investigation exactly the incoming inspection protocol the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) describes.

---

## Platform Comparison Notes

| Platform | Discrete TPM | fTPM Option | EK Cert Provisioned | Notes |
|---|---|---|---|---|
| Dell Precision 3620 | Infineon SLB9670 (optional) | No | Yes (if discrete) | TPM header on motherboard; may ship without discrete chip |
| HP EliteDesk 800 G6 | Nuvoton NPCT750 | Intel PTT | Yes (if discrete) | BIOS setting selects discrete vs PTT |
| Lenovo ThinkStation P3 | STMicro ST33 | AMD fTPM | Yes (if discrete) | BIOS clearly labels Discrete TPM vs Firmware TPM |
| Lenovo ThinkPad (any) | Infineon (most models) | Intel PTT | Yes | ThinkPads historically ship with discrete TPM |

> **Lab Note:** If your platform has no discrete TPM but offers fTPM/Intel PTT, enable it in BIOS and proceed. The software commands are identical. Note in your lab report that you are using a firmware TPM and explain the sovereignty implications.

---

## Lab Report

### 1. TPM Identity Record

| Field | Value |
|---|---|
| Platform make/model | |
| TPM type (discrete / fTPM) | |
| TPM manufacturer | |
| TPM firmware version | |
| EK certificate present | Yes / No |
| Secure Boot state | Enabled / Disabled |

### 2. PCR Baseline Table

Paste your `tpm2_pcrread sha256` output. Highlight PCRs 0, 1, and 7 as your sovereignty-critical registers.

### 3. Post-Reboot Comparison

Did PCRs 0, 1, and 7 match after reboot? Document any differences and explain them.

### 4. Sovereignty Assessment

Answer these questions from the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s chain-of-custody framework:

- Can you cryptographically verify that your hardware firmware has not been modified since you established this baseline?
- What would cause a legitimate PCR change vs. a suspicious one?
- What is the difference between this lab-level attestation and the production-grade remote attestation the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) describes?
- If your platform uses fTPM rather than a discrete TPM, what additional risk does that represent and how would you document it as an accepted risk?

---

## Key Takeaway

You have just created the hardware attestation artifact that belongs in the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s chain-of-custody evidence package under:

> *"Hardware attestation certificates from TPM and GPU attestation"*

In production, this record would be generated at the factory, sealed, and compared against at every boot. In the lab, you have done the equivalent manually establishing a known-good baseline and understanding what deviation from it means.

---

*Next: [Install LLM](4-Install-LLM.md)*

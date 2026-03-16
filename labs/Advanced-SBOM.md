# Software Bill of Materials (SBOM)

The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) identifies the Software Bill of Materials as the foundation of demonstrable software chain-of-custody, citing it as a formal US government requirement under Executive Order 14028:

> *"A sovereign AI program must maintain a comprehensive Software Bill of Materials covering every component of its stack from OS packages through AI frameworks to model weights and their training data provenance. The SBOM must be continuously maintained as software is updated, formally reviewed as part of change management, and made available to auditors on demand."*

> *"The US government has made SBOMs a formal requirement for software sold to federal agencies through Executive Order 14028 on Improving the Nation's Cybersecurity. Sovereign AI programs should adopt this requirement as a baseline regardless of whether their specific regulatory context mandates it, because an SBOM is the foundation of demonstrable software chain-of-custody."*

An SBOM is a structured, machine-readable inventory of every software component in a system  equivalent to a hardware Bill of Materials but for software. It answers the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s provenance test for every layer of the stack: *"Do you know where this software came from and can you verify it?"*

This exercise generates SBOMs for your lab environment using industry-standard tools, scans them for known vulnerabilities, and produces the software chain-of-custody artifacts that would belong in a sovereign AI evidence package.

## Prerequisites

- [Install LLM](4-Install-LLM.md) Lab completed

## SBOM Standards: A Brief Orientation

Two competing SBOM formats have emerged as standards. You will encounter both:

| Format | Full Name | Owner | Common Use |
|---|---|---|---|
| **SPDX** | Software Package Data Exchange | Linux Foundation | OS packages, open-source |
| **CycloneDX** | CycloneDX | OWASP | Application dependencies, AI model provenance |

Both are accepted by US government under EO 14028. This exercise produces both formats.

## Step 1: Install SBOM Generation Tools

### Syft  Primary SBOM Generator

Syft (from Anchore) generates SBOMs from directories and package managers. It is free, open source, and produces both SPDX and CycloneDX output.

```bash
# Install syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
syft version
```

> **Sovereign note:** In a production sovereign environment you would not `curl | sh` from the internet. You would pre-download the syft binary, verify its SHA-256 hash against the Anchore published digest, and install from your internal artifact repository. For the lab, this installation method is acceptable  note it as a gap in your lab report.

### Grype Vulnerability Scanner

Grype (also from Anchore) scans SBOMs for known CVEs using the NVD and other vulnerability databases.

```bash
# Install grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
grype version
```

### Verify installations

```bash
which syft grype
syft version && grype version
```

---

## Step 2: Generate an SBOM for the Operating System

The OS is the foundation layer. Start here.

```bash
mkdir -p ~/sbom-lab

# Generate SBOM of installed OS packages (CycloneDX format)
syft / --scope squashed -o cyclonedx-json > ~/sbom-lab/os-sbom-cyclonedx.json 2>/dev/null

# Generate same in SPDX format
syft / --scope squashed -o spdx-json > ~/sbom-lab/os-sbom-spdx.json 2>/dev/null

echo "OS SBOM generated"
wc -l ~/sbom-lab/os-sbom-cyclonedx.json
```

Inspect the SBOM:

```bash
# Count total components
cat ~/sbom-lab/os-sbom-cyclonedx.json | python3 -c "
import json, sys
data = json.load(sys.stdin)
components = data.get('components', [])
print(f'Total components: {len(components)}')
print()
print('First 10 components:')
for c in components[:10]:
    print(f'  {c.get(\"name\",\"?\")} {c.get(\"version\",\"?\")} [{c.get(\"type\",\"?\")}]')
"
```

```bash
# Show package types breakdown
cat ~/sbom-lab/os-sbom-cyclonedx.json | python3 -c "
import json, sys
from collections import Counter
data = json.load(sys.stdin)
types = Counter(c.get('type','unknown') for c in data.get('components',[]))
for t, count in types.most_common():
    print(f'  {t}: {count}')
"
```

---

## Step 3: Generate an SBOM for the Python Environment

The Ollama Python library, pip packages, and any AI frameworks in your environment are the next layer.

```bash
# Generate SBOM for installed Python packages
syft dir:/ --catalogers python-installed-package-cataloger \
  -o cyclonedx-json > ~/sbom-lab/python-sbom.json 2>/dev/null

# Alternative: use pip freeze for a simpler inventory
pip3 freeze > ~/sbom-lab/pip-packages.txt
pip3 list --format=json > ~/sbom-lab/pip-packages.json

echo "Python package count:"
wc -l ~/sbom-lab/pip-packages.txt
```

Identify the AI-specific packages and their origins:

```bash
# Filter for AI/ML relevant packages
grep -iE "torch|tensorflow|ollama|transformers|numpy|scipy|cuda|onnx|llama|hugging" \
  ~/sbom-lab/pip-packages.txt
```

## Step 4: Generate an SBOM for the Ollama Binary

Ollama runs as a native binary and systemd service — no container runtime is involved. Catalog it directly from the filesystem.

```bash
# Locate the ollama binary
which ollama

# Generate an SBOM by scanning the ollama binary and its shared libraries
syft file:$(which ollama) -o cyclonedx-json > ~/sbom-lab/ollama-sbom.json 2>/dev/null || \
  syft dir:/usr/local/bin -o cyclonedx-json > ~/sbom-lab/ollama-sbom.json 2>/dev/null

echo "Ollama binary version:"
ollama --version

# Record the binary hash for the model registry
echo "=== OLLAMA BINARY HASH ===" > ~/sbom-lab/ollama-binary-hash.txt
sha256sum $(which ollama) >> ~/sbom-lab/ollama-binary-hash.txt

# Record the systemd service definition
echo "" >> ~/sbom-lab/ollama-binary-hash.txt
echo "=== OLLAMA SYSTEMD SERVICE ===" >> ~/sbom-lab/ollama-binary-hash.txt
systemctl cat ollama 2>/dev/null >> ~/sbom-lab/ollama-binary-hash.txt || \
  echo "ollama not managed by systemd (running as user process)" >> ~/sbom-lab/ollama-binary-hash.txt

cat ~/sbom-lab/ollama-binary-hash.txt
```

> **Sovereign note:** Because this deployment runs Ollama as a native binary (not inside a container), the process isolation boundary is the host OS. The sovereignty controls for containment are therefore firewall rules, systemd `PrivateNetwork=` / `RestrictAddressFamilies=` service hardening, and SELinux/AppArmor policy — not a container networking namespace.

---

## Step 5: Scan for Vulnerabilities

With SBOMs generated, scan them with Grype:

```bash
# Scan the OS SBOM
echo "=== OS Vulnerability Scan ===" | tee ~/sbom-lab/vulnerability-report.txt
grype sbom:~/sbom-lab/os-sbom-cyclonedx.json \
  --output table 2>/dev/null | tee -a ~/sbom-lab/vulnerability-report.txt

echo "" | tee -a ~/sbom-lab/vulnerability-report.txt
echo "=== OS Vulnerability Summary ===" | tee -a ~/sbom-lab/vulnerability-report.txt
grype sbom:~/sbom-lab/os-sbom-cyclonedx.json \
  --output json 2>/dev/null | python3 -c "
import json, sys
from collections import Counter
data = json.load(sys.stdin)
matches = data.get('matches', [])
severities = Counter(m['vulnerability']['severity'] for m in matches)
print(f'Total vulnerabilities: {len(matches)}')
for sev, count in sorted(severities.items()):
    print(f'  {sev}: {count}')
" | tee -a ~/sbom-lab/vulnerability-report.txt
```

```bash
# Show critical and high severity findings
echo "" | tee -a ~/sbom-lab/vulnerability-report.txt
echo "=== Critical and High Severity ===" | tee -a ~/sbom-lab/vulnerability-report.txt
grype sbom:~/sbom-lab/os-sbom-cyclonedx.json \
  --output json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
matches = data.get('matches', [])
for m in matches:
    sev = m['vulnerability']['severity']
    if sev in ('Critical', 'High'):
        vuln = m['vulnerability']
        pkg = m['artifact']
        print(f\"{sev:8} {vuln.get('id','?'):20} {pkg.get('name','?')} {pkg.get('version','?')}\")
" | tee -a ~/sbom-lab/vulnerability-report.txt

cat ~/sbom-lab/vulnerability-report.txt
```

---

## Step 6: Map the Sovereign AI Software Stack SBOM

The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) defines a specific software stack for sovereign AI. Generate an SBOM mapped explicitly to that stack:

```bash
cat > ~/sbom-lab/sovereign-stack-inventory.txt << 'EOF'
=== SOVEREIGN AI SOFTWARE STACK INVENTORY ===
Generated: DATESTAMP
Operator: OPERATOR

Reference: Guide to Sovereign AI AI Software Stack section

Layer 1: Firmware and Low-Level Software
  BIOS/UEFI:    [manual entry required see TPM Attestation Lab]
  BMC Firmware: [manual entry required]
  GPU Firmware: [see nvidia-smi output below]

Layer 2: Operating System
  [generated from OS SBOM]

Layer 3: Process Isolation and Service Management
  Ollama service:  [see systemd unit file and binary hash]
  systemd:         [see OS SBOM]

Layer 4: AI Framework and Runtime
  [generated from Python SBOM]

Layer 5: Foundation Models
  [generated from Model Hash Registry]

Layer 6: MLOps and Pipeline Infrastructure
  [list self-hosted tools or note gaps]

Layer 7: Observability and Logging
  [list self-hosted tools or note gaps]

Layer 8: Identity and Access Management
  [list identity provider in use]

EOF

# Fill in the dynamic sections
sed -i "s/DATESTAMP/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" ~/sbom-lab/sovereign-stack-inventory.txt
sed -i "s/OPERATOR/$(whoami)@$(hostname)/" ~/sbom-lab/sovereign-stack-inventory.txt

# Append GPU firmware info
echo "" >> ~/sbom-lab/sovereign-stack-inventory.txt
echo "=== GPU FIRMWARE (nvidia-smi) ===" >> ~/sbom-lab/sovereign-stack-inventory.txt
nvidia-smi 2>/dev/null >> ~/sbom-lab/sovereign-stack-inventory.txt || echo "No NVIDIA GPU detected" >> ~/sbom-lab/sovereign-stack-inventory.txt

# Append Python AI packages
echo "" >> ~/sbom-lab/sovereign-stack-inventory.txt
echo "=== PYTHON AI/ML PACKAGES ===" >> ~/sbom-lab/sovereign-stack-inventory.txt
pip3 list --format=columns 2>/dev/null | grep -iE "torch|tensorflow|ollama|transformers|numpy|scipy|cuda|onnx|llama|hugging|accelerate|peft|trl|datasets|evaluate" >> ~/sbom-lab/sovereign-stack-inventory.txt

cat ~/sbom-lab/sovereign-stack-inventory.txt
```

## Step 7: Apply the Guide's Four Tests to Your SBOM

For each major component in your SBOM, apply the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s four software sovereignty tests:

```bash
# Generate a sovereignty assessment worksheet
cat > ~/sbom-lab/sovereignty-assessment.txt << 'EOF'
=== SOVEREIGN AI SOFTWARE STACK  SOVEREIGNTY ASSESSMENT ===
Date: DATESTAMP

Guide Reference Tests:
  1. PROVENANCE   Do you know where this software came from and can you verify it?
  2. CONTROL      Can you update/patch/replace it without depending on a foreign entity?
  3. AUDITABILITY  Can you demonstrate exactly what it does and what data it touches?
  4. CONTAINMENT  Is it prevented from communicating outside your sovereign boundary?

--- Assessment ---

Component: Ubuntu 24.04 OS
  Provenance:    Canonical Ltd (UK-incorporated). Packages signed with Canonical GPG keys.
                 Downloaded from public Ubuntu mirrors (Akamai CDN / US jurisdiction).
  Control:       Can pin package versions. Private mirror needed for full control.
  Auditability:  Open source. Full source available. Audit log via auditd.
  Containment:   Makes outbound connections for apt updates. Controllable via firewall.
  Gap:           No private package mirror in lab. Production requirement: internal mirror.

Component: Ollama (model runtime, native binary)
  Provenance:    Ollama Inc (US). Binary downloaded via curl | sh from ollama.com.
                 No container layer — binary runs directly on the host OS under systemd.
  Control:       Binary updates require connectivity to ollama.com. No offline update path.
                 Binary hash recorded in ollama-binary-hash.txt for integrity verification.
  Auditability:  Open source (MIT). Source available for review. systemd service definition
                 captures runtime parameters and network exposure.
  Containment:   Makes outbound connections during model pull and potentially at startup.
                 Isolation relies on host firewall rules and systemd service hardening
                 (PrivateNetwork, RestrictAddressFamilies) — not a container namespace.
                 See Lab-1 Outbound Connections exercise for full inventory.
  Gap:           No air-gap capable install path used. CLOUD Act jurisdiction applies to Ollama Inc.
                 No container boundary; process isolation hardening via systemd is a production requirement.

Component: IBM Granite Model Weights
  Provenance:    IBM Research. Training data documented (Stanford CRFM verified).
                 Downloaded from Ollama registry (US infrastructure).
  Control:       Hash verified locally (see Lab-3). One-time download  no runtime pull.
  Auditability:  IBM provides model cards. Training data sources documented.
  Containment:   Model runs entirely locally once pulled. No inference-time external calls.
  Gap:           Initial download required external connectivity. Production: internal registry.

[Add additional components from your SBOM here]
EOF

sed -i "s/DATESTAMP/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" ~/sbom-lab/sovereignty-assessment.txt
cat ~/sbom-lab/sovereignty-assessment.txt
```

---

## Step 8: Create the SBOM Evidence Package

Bundle all generated artifacts into a single evidence package:

```bash
# Create final SBOM evidence package
mkdir -p ~/sbom-evidence-package
cp ~/sbom-lab/os-sbom-cyclonedx.json ~/sbom-evidence-package/
cp ~/sbom-lab/os-sbom-spdx.json ~/sbom-evidence-package/
cp ~/sbom-lab/python-sbom.json ~/sbom-evidence-package/ 2>/dev/null || true
cp ~/sbom-lab/ollama-sbom.json ~/sbom-evidence-package/ 2>/dev/null || true
cp ~/sbom-lab/ollama-binary-hash.txt ~/sbom-evidence-package/ 2>/dev/null || true
cp ~/sbom-lab/pip-packages.txt ~/sbom-evidence-package/
cp ~/sbom-lab/vulnerability-report.txt ~/sbom-evidence-package/
cp ~/sbom-lab/sovereign-stack-inventory.txt ~/sbom-evidence-package/
cp ~/sbom-lab/sovereignty-assessment.txt ~/sbom-evidence-package/
cp ~/sovereign-model-registry.txt ~/sbom-evidence-package/ 2>/dev/null || echo "Run Lab-3 model hash exercise first"
cp ~/tpm-attestation-record.txt ~/sbom-evidence-package/ 2>/dev/null || echo "Run Lab-1 TPM exercise first"

# Generate a manifest of the evidence package
echo "=== SBOM EVIDENCE PACKAGE MANIFEST ===" > ~/sbom-evidence-package/MANIFEST.txt
echo "Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> ~/sbom-evidence-package/MANIFEST.txt
echo "Operator: $(whoami)@$(hostname)" >> ~/sbom-evidence-package/MANIFEST.txt
echo "" >> ~/sbom-evidence-package/MANIFEST.txt
ls -lah ~/sbom-evidence-package/ >> ~/sbom-evidence-package/MANIFEST.txt
echo "" >> ~/sbom-evidence-package/MANIFEST.txt

# Hash every file in the package for tamper-evidence
echo "=== FILE HASHES ===" >> ~/sbom-evidence-package/MANIFEST.txt
find ~/sbom-evidence-package -type f ! -name "MANIFEST.txt" | sort | while read f; do
  sha256sum "$f" >> ~/sbom-evidence-package/MANIFEST.txt
done

cat ~/sbom-evidence-package/MANIFEST.txt

echo ""
echo "Evidence package location: ~/sbom-evidence-package/"
ls ~/sbom-evidence-package/
```

## Lab Report

### 1. SBOM Statistics

| Layer | SBOM Format | Component Count | Critical CVEs | High CVEs |
|---|---|---|---|---|
| Operating System | CycloneDX | | | |
| Operating System | SPDX | | | |
| Python/AI Packages | CycloneDX | | | |
| Ollama Binary | CycloneDX | | | |

### 2. Vulnerability Assessment

For each Critical or High CVE found, document:
- CVE ID
- Affected package and version
- Description in plain language
- Is a patched version available?
- Is this component required for sovereign AI operation?

### 3. Sovereignty Gap Analysis

Apply the four [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) tests to five components of your choosing from your SBOM. Use the template in Step 7. For each failure, identify the production control that would remediate it.

### 4. SBOM Governance Questions

Answer in your own words:

- Why does the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) say SBOMs must be "continuously maintained" rather than generated once?
- EO 14028 mandates SBOMs for software sold to US federal agencies. Why should a sovereign AI program outside the US adopt this requirement regardless?
- What is the difference between an SBOM and a vulnerability scan? What does each one tell you that the other does not?
- In a production sovereign AI deployment, who should have access to the SBOM? Who should be responsible for maintaining it? How often should it be reviewed?
- Your lab SBOM was generated using tools downloaded from the internet (`curl | sh`). What does that mean for the provenance of the tools themselves? How would a production sovereign deployment handle this?

### 5. Evidence Package Inventory

List every file in your `~/sbom-evidence-package/` and describe what chain-of-custody question each one answers, mapped to the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s twelve evidence items in the Chain-of-Custody Evidence Package section.

## Key Takeaway

You now have a machine-readable inventory of every software component in your lab's AI stack, a vulnerability assessment of that inventory, and a structured sovereignty assessment applying the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s four tests. Together these form the **software chain-of-custody** layer of the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s evidence package  the artifact you would present to a regulator, auditor, or board to demonstrate that you know what is running, where it came from, and whether it can be trusted.

The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s summary statement applies directly to what you have built here:

> *"A sovereign AI software stack that passes all four tests at every layer is genuinely defensible. One that fails any of these tests at any layer has a sovereignty gap that undermines the entire program no matter how rigorous your hardware chain-of-custody has been."*

---

*Return to: [Lab Series Overview](../README.md)*

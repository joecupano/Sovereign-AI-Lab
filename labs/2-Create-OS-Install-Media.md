# Create OS Install Media

Before a single line of AI software is installed, the operating system itself must be verified. The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) identifies the OS as the foundation of the entire software stack and the software supply chain attack surface begins at the moment you download an ISO from the internet.

> *"The integrity of every layer above is only as good as the layer below it. An OS image that has been tampered with whether through a compromised mirror, a man-in-the-middle attack, or a poisoned CDN invalidates every sovereignty control built on top of it."*

In this exercise we follow the Canonical-documented verification chain for Ubuntu 24.04 LTS Desktop. This is the logical start of the sovereign AI supply chain before the OS is installed, before Ollama is configured, before a single model weight is pulled.

## Supply Chain Context

The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) describes the software supply chain as a chain of custody problem. Every hand-off is a potential point of compromise. For the OS layer, the critical hand-offs are:

```
Step 1 - Canonical builds ISO
Step 2 - Canonical signs SHA256SUMS with private GPG key
Step 3 - ISO + SHA256SUMS + SHA256SUMS.gpg published to releases.ubuntu.com
Step 4 - ISO replicated to global CDN mirrors (Akamai, regional mirrors)
  +
======   attack surface: mirror compromise, CDN poisoning, MITM
  +
Step 5 - YOU download the ISO
Step 6 - YOU verify SHA256 hash matches Canonical's signed SHA256SUMS
  +
======   This is the verification step this lab teaches
  +
Step 7 - YOU verify SHA256SUMS was signed by Canonical's known GPG key
Step 8 - Verified ISO written to USB / booted
```

Hashing the ISO, then verifying the hash file was signed by Canonical closes the CDN and mirror attack surface after Step 4. Even if the mirror was compromised, a tampered ISO will produce a different SHA-256 hash and fail verification. A tampered `SHA256SUMS` file will fail the GPG signature check against Canonical's known key.

## Prerequisites

- Another computer (not your lab server) with internet access for the initial download
- Ubuntu or Windows with WSL2 (Ubuntu) for running verification commands
- Approximately 6 GB of free disk space for the ISO
- A USB drive of 8 GB or larger for writing the install media

## Lab Exercise

By the end of this exercise you will:
- Download Ubuntu 24.04 LTS from the authoritative source
- Verify the ISO against a cryptographically signed checksum
- Confirm the signing key belongs to Canonical using GPG
- Optionally create a bootable USB stick with the Ubuntu image
- Understand where this fits in the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s hardware-to-software chain of custody

A fully documented bash script named **[create-verify-os](~/sovereign-ai-lab/code/create-verify-os)** has been included to perform all the steps above. All artifacts for this lab and labs going forward required to demonstrate sovereignty will be put in a subdirectory from your home called **artifacts**. Run the following

```bash
cd ~
mkdir artifacts
cd artifacts
create-verify-os
```

## Noteworthies

### Ubuntu Authoritative source
There is one authoritative source for Ubuntu Desktop ISOs: **https://ubuntu.com/download/desktop**
This page is operated by Canonical Ltd (UK) and served via Akamai CDN. It redirects to `releases.ubuntu.com` for the actual file.

**Do not download Ubuntu from:**
- Third-party sites (softpedia, filehippo, sourceforge, etc.)
- Torrent sites that are not `ubuntu.com/download/alternative-downloads`
- Mirror sites unless you still perform the full GPG verification

**Version note:** Canonical releases point updates (24.04.2, 24.04.4, etc.) that include hardware enablement stack updates. Always use the latest point release. The **create-verify-os** script asks for the point release version of Ubuntu.

### Sovereign supply chain
Canonical is incorporated in the United Kingdom and the Isle of Man. Ubuntu's infrastructure is hosted primarily on AWS, Azure, and Akamai  US-jurisdiction cloud providers. For sovereign deployments, this means the OS itself originates from infrastructure subject to UK law and US CLOUD Act jurisdiction. This is a known and accepted dependency for most programs; what matters is that you verify the artifact cryptographically, not that you trust the delivery network. The GPG verification in Step 4 is specifically designed to be trustworthy regardless of which network or mirror delivered the file.

## Lab Report

### 1. Verification Evidence Table

| Verification Step | Result | Notes |
|---|---|---|
| SHA256SUMS downloaded from releases.ubuntu.com | Pass / Fail | |
| SHA256SUMS.gpg downloaded | Pass / Fail | |
| GPG key 46181433FBB75451 retrieved | Pass / Fail | |
| GPG key D94AA3F0EFE21092 retrieved | Pass / Fail | |
| Key 1 fingerprint matches Canonical published value | Pass / Fail | |
| Key 2 fingerprint matches Canonical published value | Pass / Fail | |
| SHA256SUMS.gpg signature: Good signature from both keys | Pass / Fail | |
| ISO sha256sum matches SHA256SUMS entry | Pass / Fail | |
| USB write verified (if performed) | Pass / Fail / Skipped | |

### 2. Chain-of-Custody Record

Paste the output of your `~/artifacts/ubuntu-iso-verification-record.txt`.

Also paste the direct output of:

```bash
gpg --fingerprint 0x46181433FBB75451 0xD94AA3F0EFE21092
```

Include one sentence confirming you compared it against the live Ubuntu verification page (`https://ubuntu.com/tutorials/how-to-verify-ubuntu`) and noting the UTC time of that check.

### 3. Supply Chain Analysis Questions

Answer in your own words:

- At which step in the download chain does a compromised CDN mirror become detectable? What makes it detectable?
- What would a `BAD signature` on `SHA256SUMS.gpg` indicate? What would cause it?
- Why does the lab verify both that the SHA256SUMS was signed by Canonical AND that the ISO matches the SHA256SUMS? What threat does each check address independently?
- The WARNING message from GPG states the key is not certified with a trusted signature. In a production sovereign deployment, how would you establish a stronger trust anchor for Canonical's signing key than the public keyserver?
- Canonical's signing infrastructure is subject to UK law and hosted on US-jurisdiction cloud providers. How does cryptographic verification of the ISO change (or not change) the sovereignty posture of the OS layer? What residual risk remains?

### 4. Evidence Package Entry

Your `~/artifacts/ubuntu-iso-verification-record.txt` maps to which items in the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s chain-of-custody evidence package? Write one sentence describing its role in the broader software supply chain attestation record for your sovereign AI deployment.

## Key Takeaway

Every sovereign AI control built in subsequent labs [TPM attestation](Advanced-TPM-Attestation.md), [Assess the Lab](5-Assess-the-Lab.md), [LLM model hash verification](LLM-Hash-Verification.md), [SBOM generation](Advanced-SBOM.md) rests on the assumption that the OS is trustworthy. This exercise is where that trust is established and documented. Without it, every layer above is unanchored.

The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s supply chain chapter applies to the OS just as it does to AI chips and model weights:

> *"Provenance must be established at every layer, not assumed. An undocumented assumption of integrity at any layer is a gap in the chain of custody."*

Two GPG signatures and one SHA-256 comparison are what close that gap at the OS layer.

*Next: [Install Software Stack](3-Install-Software-Stack.md)*
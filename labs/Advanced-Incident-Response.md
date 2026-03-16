# Incident Response for Sovereign AI

This lab closes a critical gap in sovereign AI operations: what to do when a trust control fails.

The previous labs teach detection (hash verification, TPM attestation, network capture), but production security requires a full detect -> respond workflow. If a model hash changes unexpectedly, a PCR baseline drifts, or inference generates external network traffic, your team must respond immediately and preserve evidence.

This exercise introduces a practical, evidence-driven incident response workflow for a sovereign AI deployment.

By the end of this lab you will have:
- Simulated three realistic sovereignty-failure scenarios
- Executed a repeatable five-step response procedure
- Produced an incident record suitable for audit and compliance review
- Defined containment and recovery actions tied to chain-of-custody controls

## Prerequisites

- [Assess the Lab](5-Assess-the-Lab.md) completed
- [LLM Hash Verification](LLM-Hash-Verification.md) completed or equivalent model hash baseline available
- Optional but recommended: [Advanced TPM Attestation](Advanced-TPM-Attestation.md)
- `sudo` access
- A non-production test system (do not run this lab on operational workloads)

## Safety Notes

- This lab intentionally creates integrity failures for training purposes.
- Run only on disposable lab data or snapshots.
- Do not upload incident artifacts to third-party services.

---

## Incident Classification for This Lab

Use these severity definitions during each scenario:

| Severity | Definition | Response SLA |
|---|---|---|
| **SEV-1** | External connection during inference or confirmed integrity breach | Immediate isolation |
| **SEV-2** | Integrity signal mismatch with unclear cause | Isolate within 15 minutes |
| **SEV-3** | Expected test anomaly with no data exposure | Document and monitor |

Treat all three simulations below as **SEV-1 or SEV-2** unless proven otherwise.

---

## Step 1: Prepare an Incident Workspace and Baseline

```bash
mkdir -p ~/incident-lab/{artifacts,notes,timeline}

# Baseline timestamp
INCIDENT_START_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$INCIDENT_START_UTC" > ~/incident-lab/timeline/incident-start.txt

# Capture running services and network state
systemctl list-units --type=service --state=running > ~/incident-lab/artifacts/running-services.txt
ss -tulpen > ~/incident-lab/artifacts/open-sockets.txt
ip route show > ~/incident-lab/artifacts/routes.txt

# Capture current model hash state if script is available
if [ -x ~/source/sovereign-ai-lab/code/LLM-hash-all-model-blobs.sh ]; then
  bash ~/source/sovereign-ai-lab/code/LLM-hash-all-model-blobs.sh > ~/incident-lab/artifacts/model-hash-baseline.txt 2>&1
fi
```

Create an incident header file:

```bash
cat > ~/incident-lab/notes/incident-header.txt << 'EOF'
=== INCIDENT HEADER ===
Incident ID: IR-LAB-001
Date (UTC):
Operator:
Host:
Initial Severity:
Trigger:
Scope:
EOF
```

---

## Step 2: Simulated Compromise A - Model Blob Hash Mismatch

This simulates tampering with a local model blob by changing a single byte.

```bash
# Locate a candidate model blob (adjust path if your Ollama storage differs)
BLOB_FILE=$(find ~/.ollama/models/blobs -type f | head -1)
echo "Target blob: $BLOB_FILE"

# Record pre-tamper hash
sha256sum "$BLOB_FILE" | tee ~/incident-lab/artifacts/blob-pre.sha256

# Simulate tampering by appending one byte
printf 'X' >> "$BLOB_FILE"

# Record post-tamper hash
sha256sum "$BLOB_FILE" | tee ~/incident-lab/artifacts/blob-post.sha256

# Compare
if cmp -s ~/incident-lab/artifacts/blob-pre.sha256 ~/incident-lab/artifacts/blob-post.sha256; then
  echo "Unexpected: hash unchanged"
else
  echo "Expected: hash mismatch detected"
fi
```

Expected outcome: hash mismatch is detected immediately.

---

## Step 3: Simulated Compromise B - PCR Baseline Drift

This simulates a firmware/boot state change that alters trust measurements.

1. Capture pre-change PCR values:

```bash
tpm2_pcrread sha256:0,1,7 > ~/incident-lab/artifacts/pcr-pre.txt
cat ~/incident-lab/artifacts/pcr-pre.txt
```

2. Reboot and make one controlled BIOS/UEFI change (example: toggle Secure Boot state or a boot setting).
3. Boot back into Linux and capture post-change PCR values:

```bash
tpm2_pcrread sha256:0,1,7 > ~/incident-lab/artifacts/pcr-post.txt
cat ~/incident-lab/artifacts/pcr-post.txt

diff -u ~/incident-lab/artifacts/pcr-pre.txt ~/incident-lab/artifacts/pcr-post.txt | tee ~/incident-lab/artifacts/pcr-diff.txt
```

Expected outcome: one or more PCR values differ. Treat this as a trust boundary event until validated.

If no TPM is present, document this as a platform limitation and skip to Step 4.

---

## Step 4: Simulated Compromise C - Unexpected Outbound Connection During Inference

This simulates a model/runtime path making external network requests during inference.

1. Start packet capture:

```bash
sudo tcpdump -i any -n 'not port 22' -w ~/incident-lab/artifacts/inference-traffic.pcap &
TCPDUMP_PID=$!
echo "$TCPDUMP_PID" > ~/incident-lab/artifacts/tcpdump.pid
```

2. In a second terminal, run inference using your local model:

```bash
ollama run granite3.3:2b "Summarize sovereign AI in one paragraph."
```

3. Stop capture and inspect non-local traffic:

```bash
sudo kill "$(cat ~/incident-lab/artifacts/tcpdump.pid)"
sudo tcpdump -r ~/incident-lab/artifacts/inference-traffic.pcap -n | \
  grep -v "127.0.0.1" | grep -v "::1" | head -100 | tee ~/incident-lab/artifacts/inference-traffic-summary.txt
```

Expected outcome for sovereign mode: no external destination IPs during inference.

Any external connection here is a containment failure (SEV-1).

---

## Step 5: Execute the Response Procedure Checklist

Run this response sequence for each simulated incident.

### 5.1 Isolate

```bash
# Option A: Identify primary network interface and disable
sudo ip link show
sudo ip link set eth0 down  # If eth0 is primary interface

# Option B: stop inference service if using systemd
sudo systemctl stop ollama 2>/dev/null || true
```

Record exact UTC time isolation occurred.

### 5.2 Preserve

```bash
# Capture process, sockets, and recent logs
ps aux > ~/incident-lab/artifacts/process-snapshot.txt
ss -tupen > ~/incident-lab/artifacts/socket-snapshot.txt
journalctl -u ollama --since "-60 min" > ~/incident-lab/artifacts/ollama-journal-last60m.txt

# Optional memory capture note
cat > ~/incident-lab/notes/memory-capture-note.txt << 'EOF'
Memory capture was [performed/not performed].
Reason:
Tool used (if performed):
EOF
```

### 5.3 Investigate

```bash
# Re-run integrity checks
if [ -f ~/incident-lab/artifacts/blob-pre.sha256 ] && [ -n "$BLOB_FILE" ]; then
  sha256sum "$BLOB_FILE" > ~/incident-lab/artifacts/blob-current.sha256
fi

# Re-run TPM check if available
if command -v tpm2_pcrread >/dev/null 2>&1; then
  tpm2_pcrread sha256:0,1,7 > ~/incident-lab/artifacts/pcr-current.txt
fi
```

Answer:
- What changed?
- When did it change?
- Could this be authorized maintenance?
- Is there any evidence of external communication or data exposure?

### 5.4 Recover

```bash
cat > ~/incident-lab/notes/recovery-plan.txt << 'EOF'
Recovery Decision:
- Rebuild from known-good baseline: [yes/no]
- Reuse affected model files: [yes/no]
- Re-attest TPM baseline required: [yes/no]
- Service restore preconditions:
EOF
```

Minimum recovery standard for this lab:
- Re-pull or restore tampered model files from verified source
- Re-establish trusted PCR baseline if firmware changes were intentional
- Validate zero external network traffic during inference before returning to service

### 5.5 Document

Create a complete incident record:

```bash
cat > ~/incident-lab/notes/incident-report.md << 'EOF'
# Incident Report

## Incident Metadata
- Incident ID:
- Date/Time Detected (UTC):
- Date/Time Isolated (UTC):
- Severity:
- Reporter:
- System:

## Trigger and Detection
- Trigger source (hash check / PCR drift / network capture):
- Initial indicator:
- Detection method and command output references:

## Timeline (UTC)
- T0:
- T1:
- T2:
- T3:

## Containment Actions
- Network isolation actions:
- Service shutdown actions:

## Evidence Collected
- Hash artifacts:
- TPM artifacts:
- Network artifacts:
- Process and log snapshots:

## Root Cause Analysis
- Confirmed cause:
- Contributing factors:
- Unknowns:

## Recovery and Validation
- Rebuild/redeploy actions:
- Integrity re-validation results:
- Containment re-validation results:

## Corrective Actions
- Control gaps identified:
- Owner:
- Target completion date:

## Authorization
- Risk acceptance required? [yes/no]
- Approver:
- Date:
EOF
```

---

## Lab Report

Submit the following:

1. Incident artifacts directory listing:

```bash
find ~/incident-lab -maxdepth 3 -type f | sort
```

2. The completed incident report (`~/incident-lab/notes/incident-report.md`).

3. A one-page summary answering:
- Which simulation was most difficult to triage and why?
- How quickly did you isolate the affected system?
- Which logs or telemetry were missing?
- What preventive controls should be added to reduce recurrence?

4. A remediation table:

| Gap | Proposed Control | Owner | Due Date |
|---|---|---|---|
| | | | |

---

## Teaching Point

A sovereignty framework that can detect compromise but has no tested response plan is incomplete. Auditors and security assessors require both detection evidence and response evidence. This lab provides the response half of that proof.

*Suggested next lab: [Advanced-SBOM.md](Advanced-SBOM.md) or [10-Final-Report.md](10-Final-Report.md)*

# Model Hash Verification

This exercise implements one of the most specific and practisable controls the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) prescribes for model provenance:

> *"Model weights should be downloaded once, cryptographically hashed, and stored in your internal model registry never pulled fresh from Hugging Face at training or inference time."*

The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) frames this as a direct chain-of-custody requirement:

> *"Model Integrity Verification: Deployed models must be cryptographically verified to match approved, tested versions before being served in production. A tampered model that has been modified to introduce backdoors or bias must be detectable."*

A SHA-256 hash is the simplest, most portable chain-of-custody control for model weights. It takes seconds to produce and gives you a tamper-evident fingerprint of the exact model you approved for use. If the hash ever changes whether from a malicious modification, a corrupted download, or an unexpected update you will know.

## Prerequisites

- **[Install Software Stack](3-Install-Software-Stack.md) lab completed

## Step 1: Locate Where Ollama Stores Model Weights

Before you can hash models, you need to know where Ollama keeps them:

```bash
# Default Ollama model storage location
ls -lah ~/.ollama/models/

# Show the directory structure
find ~/.ollama/models -type f | head -30
```

Ollama stores models in a content-addressed blob store under `~/.ollama/models/blobs/`. Each file is named with a hash prefix (`sha256-<hash>`) but this is the hash Ollama uses internally for its own integrity, not a hash you control or have documented externally.

```bash
# Show the blob files for your downloaded models
ls -lah ~/.ollama/models/blobs/
```

```bash
# Show model manifests these describe which blobs make up each model
find ~/.ollama/models/manifests -type f | while read f; do
  echo "=== $f ==="
  cat "$f" | python3 -m json.tool 2>/dev/null || cat "$f"
  echo ""
done
```

## Step 2: Hash the IBM Granite Model

### 2a. Hash the Model Blobs

Hash every blob that makes up the Granite model:

```bash
# Find blobs associated with granite model
GRANITE_MANIFEST=$(find ~/.ollama/models/manifests -path "*granite*" | head -1)
echo "Manifest: $GRANITE_MANIFEST"
cat "$GRANITE_MANIFEST"
```

```bash
# Hash all model blobs
echo "=== SHA-256 Hashes of Ollama Model Blobs ===" > ~/model-hash-record.txt
echo "Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> ~/model-hash-record.txt
echo "Platform: $(hostname)" >> ~/model-hash-record.txt
echo "" >> ~/model-hash-record.txt

find ~/.ollama/models/blobs -type f | sort | while read blob; do
  hash=$(sha256sum "$blob" | awk '{print $1}')
  size=$(du -h "$blob" | awk '{print $1}')
  echo "$hash  $size  $blob" | tee -a ~/model-hash-record.txt
done

echo ""
echo "Hash record saved to ~/model-hash-record.txt"
cat ~/model-hash-record.txt
```

### 2b. Hash the Manifest Files

The manifest ties blobs together into a named model. Hash those too:

```bash
echo "" >> ~/model-hash-record.txt
echo "=== SHA-256 Hashes of Model Manifests ===" >> ~/model-hash-record.txt

find ~/.ollama/models/manifests -type f | sort | while read manifest; do
  hash=$(sha256sum "$manifest" | awk '{print $1}')
  echo "$hash  $manifest" | tee -a ~/model-hash-record.txt
done
```

## Step 3: Compare Hashes After an Ollama Update

This is where the exercise demonstrates its value. When Ollama updates or you re-pull a model, the hashes should either match (same model) or change (new version). You must know which occurred and why.

Simulate checking after a model update:

```bash
# Create a function to verify model integrity
verify_model_integrity() {
  echo "=== Model Integrity Check ===" 
  echo "Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo ""
  
  MISMATCH=0
  
  while read expected_hash size path; do
    if [ -f "$path" ]; then
      current_hash=$(sha256sum "$path" | awk '{print $1}')
      if [ "$expected_hash" = "$current_hash" ]; then
        echo "PASS  $path"
      else
        echo "FAIL  $path"
        echo "      Expected: $expected_hash"
        echo "      Current:  $current_hash"
        MISMATCH=1
      fi
    else
      echo "MISSING  $path"
      MISMATCH=1
    fi
  done < <(grep -E "^[a-f0-9]{64}" ~/model-hash-record.txt)
  
  echo ""
  if [ $MISMATCH -eq 0 ]; then
    echo "RESULT: All model blobs VERIFIED integrity confirmed"
  else
    echo "RESULT: INTEGRITY FAILURE investigate before using model"
  fi
}

verify_model_integrity
```

Save this function for reuse:

```bash
# Add to your .bashrc for persistent use
cat >> ~/.bashrc << 'EOF'

# Sovereign AI Model Integrity Verification
verify_model_integrity() {
  local record="${1:-$HOME/model-hash-record.txt}"
  echo "=== Model Integrity Check: $(date -u) ==="
  MISMATCH=0
  while read expected_hash size path; do
    if [ -f "$path" ]; then
      current_hash=$(sha256sum "$path" | awk '{print $1}')
      [ "$expected_hash" = "$current_hash" ] && echo "PASS  $(basename $path)" || { echo "FAIL  $path"; MISMATCH=1; }
    else
      echo "MISSING  $path"; MISMATCH=1
    fi
  done < <(grep -E "^[a-f0-9]{64}" "$record")
  [ $MISMATCH -eq 0 ] && echo "VERIFIED" || echo "INTEGRITY FAILURE"
}
EOF

source ~/.bashrc
```

## Step 4: Hash All Models in the Lab

Repeat the hashing for any other models you have pulled (LLaMA, Mistral, OLMo from Lab-3):

```bash
# Create a comprehensive model registry for your lab
echo "=== SOVEREIGN AI LAB MODEL REGISTRY ===" > ~/sovereign-model-registry.txt
echo "Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> ~/sovereign-model-registry.txt
echo "Operator: $(whoami)@$(hostname)" >> ~/sovereign-model-registry.txt
echo "" >> ~/sovereign-model-registry.txt

# List all models Ollama knows about
echo "=== OLLAMA MODEL INVENTORY ===" >> ~/sovereign-model-registry.txt
ollama list >> ~/sovereign-model-registry.txt
echo "" >> ~/sovereign-model-registry.txt

# Hash all blobs
echo "=== BLOB HASHES ===" >> ~/sovereign-model-registry.txt
find ~/.ollama/models/blobs -type f | sort | while read blob; do
  printf "%s  %s  %s\n" \
    "$(sha256sum "$blob" | awk '{print $1}')" \
    "$(du -h "$blob" | awk '{print $1}')" \
    "$(basename $blob)" >> ~/sovereign-model-registry.txt
done

# Hash manifests
echo "" >> ~/sovereign-model-registry.txt
echo "=== MANIFEST HASHES ===" >> ~/sovereign-model-registry.txt
find ~/.ollama/models/manifests -type f | sort | while read mf; do
  printf "%s  %s\n" \
    "$(sha256sum "$mf" | awk '{print $1}')" \
    "$mf" >> ~/sovereign-model-registry.txt
done

# Sign the registry with its own hash
echo "" >> ~/sovereign-model-registry.txt
echo "=== REGISTRY INTEGRITY HASH ===" >> ~/sovereign-model-registry.txt
sha256sum ~/sovereign-model-registry.txt >> ~/sovereign-model-registry.txt

cat ~/sovereign-model-registry.txt
```

## Step 5: Cross-Reference with Published Digests

Ollama publishes model digests in its registry. Compare your locally computed hash against the digest Ollama reports:

```bash
# Show Ollama's own digest for each model
ollama list | tail -n +2 | while read model tag id size modified; do
  echo "=== $model:$tag ==="
  echo "Ollama ID: $id"
  # Show the manifest for this model
  MODEL_PATH=$(echo "$model" | tr '/' '_' | tr ':' '_')
  find ~/.ollama/models/manifests -name "*" -type f | xargs grep -l "$id" 2>/dev/null | head -1
  echo ""
done
```

**Discussion question for lab report:** Ollama's internal hash prefix on blob filenames uses SHA-256 but it is the hash Ollama computed, not one you independently verified from the model publisher. What is the difference? What would a fully sovereign model registry require beyond what Ollama provides out of the box?

## Step 6: Understand the Production Control

In a production sovereign deployment, what you have built manually here would be implemented as:

```bash
# Production sovereign model registry workflow (conceptual)
# 1. Download model ONCE to air-gapped staging system
# 2. Compute hash on staging
# 3. Compare against publisher-signed digest
# 4. If verified, transfer to internal model registry (JFrog Artifactory / Nexus)
# 5. Never pull from Hugging Face or Ollama registry at runtime
# 6. All production systems pull ONLY from internal registry
# 7. Hash verified at deploy time and periodically in production

# Minimum viable sovereign model pull (for reference):
EXPECTED_HASH="<hash from approved internal registry>"
ollama pull granite3.3
ACTUAL_HASH=$(sha256sum ~/.ollama/models/blobs/sha256-* | awk '{print $1}' | sort | sha256sum | awk '{print $1}')

if [ "$EXPECTED_HASH" = "$ACTUAL_HASH" ]; then
  echo "Model approved for sovereign deployment"
else
  echo "Model hash mismatch DO NOT DEPLOY"
  ollama rm granite3.3
fi
```

## Lab Report

### 1. Model Registry Table

| Model Name | Version | Blob Count | Composite Hash (first 16 chars) | Pull Date | Approved For Use |
|---|---|---|---|---|---|
| granite3.3 | | | | | |
| llama3.2 | | | | | |
| (others) | | | | | |

### 2. Integrity Verification Results

Run `verify_model_integrity` and paste the output.

### 3. Analysis Questions

- What is the difference between the hash Ollama stores internally and an independently computed SHA-256?
- If a malicious actor modified a model's weights to introduce a backdoor, what would you observe in your hash record?
- Why does the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) say models should be downloaded once and never pulled fresh from external repositories at inference time? What specific attack does this prevent?
- How does your lab model registry differ from the production sovereign model registry the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) describes? What tooling would close that gap?

### 4. Chain-of-Custody Evidence Artifact

Your `~/sovereign-model-registry.txt` file is a chain-of-custody evidence artifact for the **Foundation Models and Training Data** layer of the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s software stack. In one paragraph, describe how it would be incorporated into the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s chain-of-custody evidence package.

## Key Takeaway

Model weights are the strategic asset your sovereign AI program exists to protect. A SHA-256 hash costs nothing to compute and makes tampering detectable. The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) states that a model that has been modified to introduce backdoors or bias must be detectable this exercise shows you exactly how that detection works.


*Next: [SBOM Exercise](SBOM.md)*

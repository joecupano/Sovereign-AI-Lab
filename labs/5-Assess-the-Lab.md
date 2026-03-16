# Assess the Lab

This exercise makes visible what your lab system actually does on the network when you install and run Ollama. It is one of the most important exercises in the entire lab series because it confronts a core principle from the *[Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)* directly:

> *"Every component of the software stack that touches sovereign data, model weights, or infrastructure must be under your jurisdiction, auditable by you, and controllable by you with no undisclosed external dependencies."*

The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)'s four tests for every software component are:

| Test | Question |
|---|---|
| **Provenance** | Do you know where this software came from and can you verify it? |
| **Control** | Can you update, patch, or replace it without depending on a foreign entity? |
| **Auditability** | Can you demonstrate exactly what it does and what data it touches? |
| **Containment** | Is it prevented from communicating outside your sovereign boundary without explicit authorization? |

This exercise specifically tests **Auditability** and **Containment**. You will capture and classify every outbound network connection made by Ollama during model pull and inference. What you find is the gap between your current lab and a production sovereign deployment.

## Prerequisites

- **[Install Software Stack](3-Install-Software-Stack.md)** is completed
- **[Install LLM](4-Install-LLM.md)** is completed

## Exercise 1: What Is Listening Before Ollama Starts?

Before starting Ollama, record the clean network state. This is your baseline.

```
# Show all listening ports and established connections
ss -tulnp > ~/network-baseline-ports.txt
cat ~/network-baseline-ports.txt

# Show current routing table
ip route show > ~/network-baseline-routes.txt
cat ~/network-baseline-routes.txt
```

Record your findings:

| Protocol | Port | Process | Purpose |
|---|---|---|---|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

## Exercise 2: Capture Connections When Ollama Starts

Open two terminal windows side by side.

**Terminal 1: Start the packet capture**

```
sudo tcpdump -i any -n 'not port 22' -w ~/lab1-ollama-start.pcap &
TCPDUMP_PID=$!
echo "Capture PID: $TCPDUMP_PID"
```

**Terminal 2 Start Ollama**

```
ollama serve&
sleep 15
```

**Terminal 1 Stop the capture and inspect**

```
sudo kill $TCPDUMP_PID
sudo tcpdump -r ~/lab1-ollama-start.pcap -n | grep -v "127.0.0.1" | grep -v "::1" | head -60
```

Now use `ss` to see what Ollama is listening on:

```
ss -tulnp | grep ollama
```

**Expected output:** Ollama binds to `127.0.0.1:11434` by default. Note whether it binds to `0.0.0.0` (all interfaces) that is a sovereignty concern on a networked system.

Record:
- What address and port is Ollama listening on?
- Does it make any outbound connections at startup?
- What remote IPs appear in the pcap?

## Exercise 3: Capture Connections During a Model Pull

This is where the most significant outbound traffic occurs. We will pull a second model here because granite4:3b was already cached in the previous lab. Pulling a fresh model generates the network traffic we want to capture when an LLM pull occurs.

**Terminal 1 Start capture:**

```
sudo tcpdump -i any -n 'not port 22' -w ~/llm-model-pull.pcap &
TCPDUMP_PID=$!
```

**Terminal 2 Pull the model:**

```
ollama pull granite3.3:2b
```

Wait for the pull to complete fully.

**Terminal 1 Stop and analyse:**

```
sudo kill $TCPDUMP_PID

# Extract unique destination IPs
sudo tcpdump -r ~/llm-model-pull.pcap -n | grep -oP '\d+\.\d+\.\d+\.\d+' | sort -u > ~/llm-pull-ips.txt
cat ~/llm-pull-ips.txt
```

Resolve each IP to identify who owns it:

```
while read ip; do
  echo "--- $ip ---"
  whois $ip | grep -E "OrgName|org-name|netname|descr" | head -3
  dig -x $ip +short
  echo ""
done < ~/llm-pull-ips.txt
```

Build your connection inventory:

| Destination IP | Hostname/Org | Port | Purpose | Sovereignty Risk |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |
| | | | | |

**Key questions to answer:**
- Where are model weights being served from?
- What CDN or cloud provider is involved?
- Under whose legal jurisdiction does that infrastructure operate?
- Does this match what the [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) says about the CLOUD Act?

## Exercise 4: Capture Connections During Inference

Now capture what happens when you run a prompt no model pull, just a query to an already-loaded model.

**Terminal 1 Start capture:**

```bash
sudo tcpdump -i any -n 'not port 22 and not host 127.0.0.1' -w ~/llm-inference.pcap &
TCPDUMP_PID=$!
```

**Terminal 2 Run an inference query**

```bash
ollama run granite3.3:2b "What is sovereign AI?"
```

**Terminal 1 Stop and analyse**

```bash
sudo kill $TCPDUMP_PID
sudo tcpdump -r ~/llm-inference.pcap -n | head -30
```

**Expected result for a sovereign deployment:** Zero external connections. The query should be entirely local model loaded in memory, inference on local GPU/CPU, response returned locally.

**If you see external connections during inference:** Record them. This is a sovereignty failure. The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) identifies this as a containment failure that "quietly defeats all hardware sovereignty efforts."

## Exercise 5: Identify Ollama Telemetry and Update Behaviour

Ollama checks for updates and may phone home. Investigate:

```bash
# Check Ollama environment variables that control update behaviour
ollama --help 2>&1 | grep -i update

# Review the Ollama systemd service if installed as a service
systemctl cat ollama 2>/dev/null || echo "Ollama not running as systemd service"

# Check if Ollama has any scheduled tasks
crontab -l 2>/dev/null
ls /etc/cron* 2>/dev/null | grep ollama
```

Check what environment variables can control Ollama's network behaviour:

```bash
# Key variables for sovereign operation
echo "OLLAMA_HOST controls binding address"
echo "OLLAMA_ORIGINS controls CORS"
echo "Set OLLAMA_NOPRUNE=1 to prevent automatic model pruning"
```

For a sovereign deployment, document what would need to be set to prevent all unsolicited outbound connections:

```bash
# Example sovereign Ollama service configuration
cat << 'EOF'
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
Environment="OLLAMA_NOPRUNE=1"
# Block outbound via firewall rule see below
EOF
```

## Exercise 6: Firewall Rule Simulate Sovereign Containment

Apply a firewall rule that blocks Ollama from making outbound connections, then verify inference still works:

```bash
# Get the Ollama process UID
OLLAMA_UID=$(id -u ollama 2>/dev/null || echo "running as your user")
echo "Ollama UID: $OLLAMA_UID"

# Block outbound traffic on port 443 from the ollama process (if running as ollama user)
# For lab purposes block all outbound except established connections
sudo iptables -A OUTPUT -m owner --uid-owner $(whoami) -p tcp --dport 443 -j LOG --log-prefix "OLLAMA-BLOCKED: "
sudo iptables -A OUTPUT -m owner --uid-owner $(whoami) -p tcp --dport 80 -j LOG --log-prefix "OLLAMA-BLOCKED: "

# Run inference and check if it still works
ollama run granite3.3:2b "Explain chain of custody in one sentence."

# Check for blocked connection attempts in system log
sudo journalctl -k | grep "OLLAMA-BLOCKED" | tail -20
```

Remove the rules after testing:

```bash
sudo iptables -D OUTPUT -m owner --uid-owner $(whoami) -p tcp --dport 443 -j LOG --log-prefix "OLLAMA-BLOCKED: "
sudo iptables -D OUTPUT -m owner --uid-owner $(whoami) -p tcp --dport 80 -j LOG --log-prefix "OLLAMA-BLOCKED: "
```

## Lab Report

Complete the following for your lab report:

### 1. Connection Inventory Table

| Phase | Destination | Owner/Jurisdiction | Port | Required for Function? |
|---|---|---|---|---|
| Startup | | | | |
| Model Pull | | | | |
| Inference | | | | |

### 2. Sovereignty Assessment

For each external connection found, classify it:

- **Acceptable for development** necessary for initial setup, would be eliminated in production
- **Acceptable for production with controls** can be mitigated by internal mirror, HSM, or firewall
- **Unacceptable for sovereign production** eliminates entirely or substitutes with sovereign alternative

### 3. Gap Statement

Write a one-paragraph gap statement: *"This lab environment differs from a production sovereign deployment in the following ways..."*

### 4. Remediation Plan

For each unacceptable connection, describe the production control from the *[Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) to Sovereign AI* that would address it. Reference the relevant [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) section.

## Key Takeaway

You are not expected to fix these gaps in the lab. The point is to **see them**, **name them**, and **document them**. The [Guide](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf) states:

> *"The goal is not perfect sovereignty. It is demonstrable, auditable, and legally defensible sovereignty at every layer you can control."*

You cannot defend what you cannot observe. This exercise is the observability foundation for everything that follows.

*Optional: For a complete detect→respond workflow built on these controls, see [Incident Response](Advanced-Incident-Response.md).*

*Next Lab: [CPU vs GPU](6-CPU-vs-GPU.md)*

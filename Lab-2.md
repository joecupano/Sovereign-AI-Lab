# Lab 2

## Lecture: Data Center & Cloud

### Useful Background
*Where does AI "live" and breathe? Data centers, VRAM, and the environmental cost of "The Cloud."*

-   **What is a Data Center**: Understanding servers, racks, and high-speed networking.
-   **Cloud and Hyperscalers:** Discuss "Compute-as-a-Utility" and the roles of Amazon (AWS), Microsoft (Azure), and Google Cloud in hosting AI.
-   **Power & Water:** Explain the massive energy requirements in training a model like GPT-4 and the water used to cool the "brains" of AI.
-   **Quantization:** Explain how we "shrink" massive models to fit onto 6GB of VRAM (the limit of the RTX 3050) using 4-bit or 8-bit math.
-   **Activity:** Calculating the estimated carbon footprint and water usage of a 30-minute AI brainstorming prompt session.

## Lab: Auditing CPU vs GPU

We will continue to use the IBM Granite 8B model to scientifically measure and visualize the "Compute Gap" between general-purpose (CPU) and parallel (GPU) architectures.

As mentioned, when **Ollama** starts it will automatically detect your GPU and use it. But we can disable GPU use and have Ollama just use the CPU to demonstrate the difference in horsepower delivered between GPU and CPU in AI use. In this lab we will do just that and generate metrics for comparison. Let’s start by first rebooting the Lab server.

### Step 1: Setup

To see the difference, we need to monitor three resources simultaneously opening three separate terminal windows. We will refer to them as **Monitoring**, **Logging**, **Command** terminals respectively.

**Monitoring Terminal** is for monitoring "GPU" and "VRAM" bars**.** Open a terminal and run the following command.

```
nvtop
``` 

**Logging Terminal** is where monitor logs looking for lines like LLM offloading 32/32 layers to GPU Run the following command

```
journalctl -u ollama -f
```

**Command Terminal** is where we will run AI commands.

![MONITOR, LOG, COMMAND Terminals](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab2_ThreeTerms.png "MONITOR, LOG, COMMAND Terminals")

### Step 2: GPU Baseline (Standard Mode)

In the **Command Terminal**, run the Granite model with the **--verbose flag**. This flag is critical because it tells Ollama to print precise timing data after every response.

```
ollama run granite4:3b –verbose
```

In the chat prompt enter a query such as *"Write a 100-word essay on why Open Science is important for AI safety."* Once the model finishes, look at the bottom of the response. Record the following:

- eval rate: (e.g., 55.4 tokens/s)
- total duration: (e.g., 2.1s)
- VRAM usage: (Check nvtop while it is running)

Your **Monitoring Terminal** may show activity similar to this during the run:

![GPU Activity](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab2_GPU-Run.png "GPU Activity")

### Step 3: CPU Stress Test (Forced Mode)

Now, we will intentionally "break" the hardware acceleration to force the CPU to do all the work. Exit the current prompt chat in **Command Terminal** by typing **/exit** or press **Ctrl+D**. Next, will stop the background service from the **Command Terminal** and restart it with the GPU hidden.

```
sudo systemctl stop ollama
export CUDA_VISIBLE_DEVICES=-1
ollama serve
```

Leave this terminal window running; it is now your temporary manual server.

Open a **new terminal** which will refer to as the **Test Terminal** and run the following:

```
ollama run granite4:3b --verbose
```

Use the exact same chat prompt entry as before and record the new metrics.

- eval rate: likely to drop
- total duration: likely to increase
- CPU Usage: all CPU cores spike to 100%.

Your **Monitoring Terminal** may show activity similar to this during the run:

![GPU Activity](https://raw.githubusercontent.com/wiki/joecupano/sovereign-ai-course/pix/Lab2_CPU-Run.png "GPU Activity")

GPU use seen is by the desktop environment.

### Step 4: Lab Analysis & Report

Complete the following comparison table:

| **Metric**                  | **GPU Test** | **CPU Test** | **% Difference** |
|-----------------------------|--------------|--------------|------------------|
| **Tokens per Second**       |              |              |                  |
| **Total Response Time**     |              |              |                  |
| **"Feel" (Lag/Smoothness)** |              |              |                  |

Students submit a report answering these three data-driven questions:

**1. Performance Multiplier**
- *Question:* Is the GPU faster and by how much. Explain why this makes "Real-Time AI" impossible on standard office computers.

**2. VRAM vs. RAM**
- *Question* When the GPU was disabled, what did the logs say about "offloading layers"?
- *Question* Why does the CPU take so much longer to "read" the model from RAM compared to VRAM?

**3. Energy/Heat Observation.**
- *Question:* When viewing the **moinitoring terminal** Which hardware component got hotter during its respective test? What does this tell us about the "Work" being performed?

## Optional Lab
- **Quantization Exploration**. Compare performance of the same model in different "weights" between **llama3.1:8b** (high quality, slow) and **llama3.1:8b-instruct-q4_0** (lower quality, fast).
- **Monitoring Thermal Loads**. Run **nvtop** to watch the clock speeds and temperature of the RTX 3050 graphically while running a heavy batch of prompts using **nvtop**. Students must identify the "Temperature" and "Fan Speed" spikes during heavy inference.
- **Multi-Model Concurrency**. Try to run two models simultaneously (e.g., Mistral and Llama 3) to see at what point the 6GB VRAM "OOMs" (Out of Memory).

# GPU vs CPU

## Architecture
CPUs are designed for latency-optimized, sequential processing. They have a small number of powerful cores (typically 8–64) with large caches, deep branch prediction, and out-of-order execution. They are all built to minimize the time to complete any single task as fast as possible.

GPUs, by contrast, are designed for throughput-optimized, massively parallel processing and have thousands of smaller cores plus specialized Tensor Cores, purpose-built to execute thousands of operations simultaneously.

|    Dimension     |                   CPU                   |                GPU              |
|------------------|-----------------------------------------|---------------------------------|
| Core Count       | Tens (high-IPC)                         | Thousands (simpler)             |
| Optimization     | Latency                                 | Throughput                      |
| Memory Bandwidth | ~300–400 GB/s                           | ~3+ TB/s (HBM)                  |
| Math Throughput  | Low–Moderate                            | Very High                       |
| Best AI Use      | Inference, small models, pre-processing | Training, large model inference |

### Cores and Optimization
AI training and inference are basically linear algebra workloads. These operations are parallel, meaning they can be split into thousands of independent sub-operations that run simultaneously. GPUs with their thousands of simple cores were built exactly for this pattern. A CPU doing a large matrix multiply runs operations primarily serially while a GPU runs them all at once.

### Memory Bandwidth
Perhaps the most critical difference between GPUs and CPUs for AI. GPUs have extremely high memory bandwidth at TB/s while a high-end CPU like Intel Xeon or AMD EPYC tops out around 300–400 GB/s. Since AI models are memory-bandwidth-bound this is a massive advantage for GPUs.

### Precision and Tensor Operations
GPUs with their dedicatedcCores that natively accelerate mixed-precision operations deliver dramatically higher throughput for the arithmetic AI needs. CPUs are far behind in raw throughput.

## CPU and TPU Strengths
CPUs are better for AI workloads that involve complex control flow, sparse or irregular data access patterns, small batch inference, and pre/post-processing pipelines. They're also essential as the host processor orchestrating GPU work. Many production inference systems use CPUs for lightweight models where the overhead of dispatching to a GPU isn't worth it.

While GPUs deliver far more FLOPS per watt on matrix workloads than CPUs for large-scale AI, this gap is being challenged by dedicated AI ASICs like Google's TPUs

## Auditing CPU vs GPU
We will continue to use the IBM Granite 4:3B model to scientifically measure and visualize the performance gap between general-purpose (CPU) and parallel (GPU) architectures.

When **Ollama** starts it will automatically detect your GPU and use it. But we can disable GPU use and have Ollama just use the CPU to demonstrate the difference in horsepower delivered between GPU and CPU in AI use. In this lab we will do just that and generate metrics for comparison. Let’s start by first rebooting the Lab server.

### Setup
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

![MONITOR, LOG, COMMAND Terminals](/pix/Lab2_ThreeTerms.png "MONITOR, LOG, COMMAND Terminals")

### Data Gathering
A table to document the data we will be gathering:

| **Metric**                  | **GPU Test** | **CPU Test** | **% Difference** |
|-----------------------------|--------------|--------------|------------------|
| **Tokens per Second**       |              |              |                  |
| **Total Response Time**     |              |              |                  |
| **"Feel" (Lag/Smoothness)** |              |              |                  |

### GPU Baseline (Standard Mode)
In the **Command Terminal**, run the Granite model with the **--verbose flag**. This flag is critical because it tells Ollama to print precise timing data after every response.

```
ollama run granite4:3b –verbose
```

In the chat prompt enter a query such as *"Write a 100-word essay on why Open Science is important for AI safety."* Once the model finishes, look at the bottom of the response. Record the following:

- eval rate: (e.g., 55.4 tokens/s)
- total duration: (e.g., 2.1s)
- VRAM usage: (Check nvtop while it is running)

Your **Monitoring Terminal** may show activity similar to this during the run:

![GPU Activity](/pix/Lab2_GPU-Run.png "GPU Activity")

### CPU Stress Test (Forced Mode)
Now, we will intentionally "break" the hardware acceleration to force the CPU to do all the work. Exit the current prompt chat in **Command Terminal** by typing **/exit** or press **Ctrl+D**. Next, will stop the background service from the **Command Terminal** and restart it with the GPU hidden.

```
sudo systemctl stop ollama
export CUDA_VISIBLE_DEVICES=-1
export OLLAMA_DEBUG=1
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

![GPU Activity](/pix/Lab2_CPU-Run.png "GPU Activity")

GPU use seen is by the desktop environment.

### Findings
Fomr the data gathered, ask yourself these questios
**1. Performance Multiplier**
- Is the GPU faster and by how much. Explain why this makes "Real-Time AI" impossible on standard office computers.

**2. VRAM vs. RAM**
- When the GPU was disabled, what did the logs say about "offloading layers"?
- Why does the CPU take so much longer to "read" the model from RAM compared to VRAM?

**3. Energy/Heat Observation.**
- When viewing the **moinitoring terminal** which hardware component got hotter during its respective test? What does this tell us about the "Work" being performed?

# CPU vs GPU

## Architecture
CPUs are designed for latency-optimized, sequential processing. They have a small number of powerful cores with large caches, deep branch prediction, and out-of-order execution. They are built to minimize the time to complete any single task as fast as possible.

GPUs, by contrast, are designed for throughput-optimized, massively parallel processing and have thousands of smaller cores plus specialized Tensor Cores, purpose-built to execute thousands of operations simultaneously.

|    Dimension     |               CPU                   |                GPU               |
|------------------|-------------------------------------|----------------------------------|
| Core Count       | Tens (high-IPC)                     | Thousands (simpler)              |
| Optimization     | Latency                             | Throughput                       |
| Memory Bandwidth | ~40–60 GB/s (DDR4)                  | ~200+ GB/s (GDDR6)               |
| Math Throughput  | Low–Moderate                        | Very High (Tensor Cores)         |
| Best AI Use      | Small models, pre/post-processing   | Training, large model inference  |

### Cores and Optimization
AI training and inference are fundamentally linear algebra workloads: multiplying large matrices of numbers together to produce predictions. These matrix operations are **embarrassingly parallel**: they can be split into thousands of independent sub-operations with no dependency on each other, all able to run at the same time. GPUs, with their thousands of simple cores, were built exactly for this pattern. A CPU doing a large matrix multiply runs most of those operations serially while a GPU runs them all at once.

**Why this matters in the lab:** When you run Ollama on the GPU you will see many tokens generated per second because every layer of the model is computed in parallel across thousands of CUDA or ROCm cores. When you force CPU-only mode, tokens per second drops sharply because the CPU runs the same operations mostly serially.

### Memory Bandwidth
Memory bandwidth is the single most important hardware constraint for AI inference. After a model is loaded, generating each token requires reading the model weights from memory once per layer. The consumer GPU in this lab uses GDDR6 memory, sustaining ~200 GB/s. The workstation's DDR4 RAM tops out at ~40–60 GB/s, roughly a 4x bandwidth difference. On top of that, dedicated Tensor Cores on the GPU perform matrix multiply operations far more efficiently than the CPU's general-purpose arithmetic, compounding the speedup beyond the raw bandwidth ratio.

**Why this matters in the lab:** Your measured tokens-per-second speedup will likely exceed the raw 4x bandwidth figure because Tensor Cores are also doing more useful work per cycle. Both factors (bandwidth and specialized compute) together explain the GPU advantage you observe. Connect your measured result to these numbers in the Findings section.

### Precision and Tensor Operations
Modern AI models run in reduced precision (FP16, BF16, INT8, INT4) rather than the 64-bit floating point a CPU is optimized for. NVIDIA GPUs since Volta (2017) and AMD GPUs since RDNA3 include dedicated Tensor Cores that perform mixed-precision matrix operations at dramatically higher throughput than standard arithmetic. CPUs lack equivalent dedicated silicon for this workload.

## CPU Strengths
CPUs are better for AI workloads that involve complex control flow, sparse or irregular data access patterns, small batch inference, and pre/post-processing pipelines. They are also essential as the host processor orchestrating GPU work. Many production inference systems use CPUs for lightweight models where the overhead of dispatching to a GPU is not justified.

## Auditing CPU vs GPU
We will use the IBM Granite 4:3B model to measure and visualize the performance gap between general-purpose (CPU) and parallel (GPU) architectures. By running the same prompt twice (once with the GPU enabled and once with it hidden) you generate a controlled, side-by-side comparison on identical hardware.

When Ollama starts it automatically detects your GPU and offloads all model layers to it. In this lab you will override that behaviour using an environment variable to force CPU-only mode, then compare the results.

### What Ollama Verbose Output Looks Like
When you run `ollama run <model> --verbose`, Ollama prints a timing summary after every response. Here is a representative example:

```
prompt eval count:    14 token(s)
prompt eval duration: 0.145s
prompt eval rate:     96.55 tokens/s
eval count:           198 token(s)
eval duration:        3.571s
eval rate:            55.46 tokens/s        ← tokens generated per second
total duration:       3.857s               ← wall-clock time for full response
load duration:        0.138s
```

- **eval rate**: how many output tokens the model generates per second. This is your primary performance metric. Higher is faster.
- **total duration**: wall-clock time from sending the prompt to receiving the full response.
- **load duration**: time to load the model into memory (only significant on the first run).

### What the Serve Log Shows
Ollama logs to the terminal where `ollama serve` is running. With `OLLAMA_DEBUG=1` set you will see a line like:

```
llm server loaded in ...  offload 32/32 layers to GPU
```

- **`offload 32/32 layers to GPU`** means all 32 transformer layers of the model are running on the GPU (the expected result when VRAM is sufficient).
- **`offload 0/32 layers to GPU`** means no layers are running on the GPU (what you will see in CPU-only mode).
- A number between 0 and 32 means partial offloading: the model is too large for VRAM and the remaining layers fall back to CPU, reducing performance.

### Setup
To see the difference you need three terminal windows open simultaneously. Open them now and arrange them so you can see all three at once.

**Terminal 1: Monitor** tracks GPU and VRAM usage in real time:

```bash
nvtop
```

**Terminal 2: Serve** runs the Ollama server and shows debug log output. You will watch this for the `offload N/32 layers to GPU` line:

```bash
export OLLAMA_DEBUG=1
ollama serve
```

> Leave this terminal running throughout the lab. Do not close it or press Ctrl-C during tests.

**Terminal 3: Command** is where you run inference queries.

![MONITOR, SERVE, COMMAND Terminals](/pix/GPU_ThreeTerms.png "MONITOR, SERVE, COMMAND Terminals")

### Data Gathering
Copy this table into your lab report and fill it in as you complete each test.

The % Difference column is calculated as:
```
% Difference = ((GPU value − CPU value) / CPU value) × 100
```

| **Metric**                  | **GPU Test** | **CPU Test** | **% Difference** |
|-----------------------------|--------------|--------------|------------------|
| **Tokens per Second**       |              |              |                  |
| **Total Response Time**     |              |              |                  |
| **Layers Offloaded to GPU** |              |              | n/a              |
| **"Feel" (Lag/Smoothness)** | Smooth       | Choppy       | n/a              |

### GPU Baseline (Standard Mode)
In **Terminal 3: Command**, run the Granite model with the `--verbose` flag. This flag tells Ollama to print the timing summary shown above after every response.

```bash
ollama run granite4:3b --verbose
```

At the chat prompt enter the following query and wait for it to complete:

> *Write a 100-word essay on why Open Science is important for AI safety.*

Once the model finishes, record the `eval rate` and `total duration` from the verbose output at the bottom of the response. While it is running:
- Check **Terminal 1: Monitor** for GPU and VRAM bar activity.
- Check **Terminal 2: Serve** for the `offload 32/32 layers to GPU` confirmation line.

**Expected results:**
- eval rate in the range of 30–80 tokens/s (depends on GPU model)
- All 32 layers offloaded to GPU
- GPU utilisation visible in nvtop
- Response feels smooth and continuous

Your **Monitor terminal** may show activity similar to this during the run:

![GPU Activity](/pix/GPU-Run.png "GPU Activity")

Type `/exit` or press **Ctrl-D** to leave the chat when done.

### CPU Stress Test (Forced Mode)
Now force CPU-only mode by stopping Ollama and restarting it with the GPU hidden. Setting the visible GPU device list to `-1` tells the GPU runtime there are no GPUs available, so Ollama falls back entirely to the CPU.

Stop Ollama in **Terminal 2: Serve** with **Ctrl-C**, then restart it with the GPU hidden:

For NVIDIA GPUs:
```bash
export CUDA_VISIBLE_DEVICES=-1
export OLLAMA_DEBUG=1
ollama serve
```

For AMD GPUs:
```bash
export HIP_VISIBLE_DEVICES=-1
export OLLAMA_DEBUG=1
ollama serve
```

For Intel GPUs:
```bash
export ONEAPI_DEVICE_SELECTOR=opencl:cpu
export OLLAMA_DEBUG=1
ollama serve
```

Watch **Terminal 2: Serve** for the confirmation line. You should now see:

```
offload 0/32 layers to GPU
```

This confirms the model is running entirely on the CPU. In **Terminal 3: Command**, run the exact same query:

```bash
ollama run granite4:3b --verbose
```

> *Write a 100-word essay on why Open Science is important for AI safety.*

Record the new metrics once the response completes.

**Expected results:**
- eval rate drops to roughly 2–8 tokens/s (slower than GPU)
- 0/32 layers offloaded to GPU
- All CPU cores spike to 100% (visible in btop or top)
- Response arrives in noticeable chunks; the model stutters

Your **Monitor terminal** may show activity similar to this during the run:

![CPU Activity](/pix/CPU-Run.png "CPU Activity")

The residual GPU activity shown is from the desktop environment, not the model.

### Reset to GPU Mode
Stop Ollama in **Terminal 2: Serve** with **Ctrl-C**, then clear the environment variables and restart normally.

For NVIDIA GPUs:
```bash
unset CUDA_VISIBLE_DEVICES
unset OLLAMA_DEBUG
ollama serve
```

For AMD GPUs:
```bash
unset HIP_VISIBLE_DEVICES
unset OLLAMA_DEBUG
ollama serve
```

For Intel GPUs:
```bash
unset ONEAPI_DEVICE_SELECTOR
unset OLLAMA_DEBUG
ollama serve
```

Verify GPU is restored by checking **Terminal 2: Serve** for `offload 32/32 layers to GPU` and **Terminal 1: Monitor** for GPU activity when you run a query.

### Findings
Use the data in your table to answer the following questions in your lab report.

**1. Performance Multiplier**
- By what factor is GPU tokens/s higher than CPU tokens/s? (divide GPU eval rate by CPU eval rate)
- How does this ratio compare to the ~4x GDDR6 vs DDR4 bandwidth advantage in the Architecture table? Your measured speedup likely exceeds 4x. What other factor described in the Architecture section explains the additional gain?
- Using your CPU tokens/s result, estimate how long a 2,000-token response would take on CPU vs GPU. Explain why this makes real-time AI interaction impractical on a standard CPU.

**2. VRAM vs RAM: The Offloading Connection**
- In the GPU test, what did **Terminal 2: Serve** show for layers offloaded? What about in the CPU test?
- RAM and VRAM both store the model weights, but at very different bandwidths. Using the bandwidth numbers in the Architecture table, explain why the CPU takes so much longer to read each token's worth of weights compared to the GPU.
- If a future model had 64 layers and your GPU only had enough VRAM for 48 of them, what would the `offload` log line look like? How would you expect performance to compare to the full-GPU case?

**3. Energy and Heat**
- During the GPU test, which component in **Terminal 1: Monitor** showed the highest temperature and utilisation?
- During the CPU test, which component showed the highest temperature and utilisation?
- What does the location of heat generation tell you about which component performed the majority of the arithmetic work in each test?


---

> **Going Further: Data Center GPUs.** The consumer GDDR6 GPUs used in this lab (~200 GB/s) are not the ceiling of GPU memory technology. Data center accelerators such as the NVIDIA H100 use High Bandwidth Memory (HBM3), sustaining over 3 TB/s, roughly 15x the bandwidth of DDR4 and 10x that of consumer GDDR6. This is why server-grade AI accelerators are subject to export controls, why nations are competing to secure TSMC fabrication capacity, and why the Guide treats GPU access as a geopolitical sovereignty question. The principle you observed in this lab (that memory bandwidth and specialized compute together drive AI inference performance) scales directly to those stakes.

*Optional: For a Python-automated version of this benchmark that logs results to CSV for analysis, see [Automated Benchmarking](Advanced-Automated-Benchmarking.md).*

*Next Lab: [Power Consumption](7-Power-Consumption.md)*

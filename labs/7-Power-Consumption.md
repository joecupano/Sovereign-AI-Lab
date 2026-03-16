# Power Consumption

Much has been said on the power and cooling requirements to run AI. We will venture to demonstrate this on a smaller scale with our lab using a piece of hardware called a [Kill-A-Watt](https://www.amazon.com/dp/B00009MDBU) which is readily available for ~$35 USD. When plugged in-between your server and a wall outlet it can store and display power usage over time. You will need this device to perform this lab.

## Physical Setup
- Plug the Kill-a-Watt into the wall outlet
- Plug the server power cable into the Kill-a-Watt
- Power on the machine
- Before running any model, observe and note the idle baseline wattage. We will use this number as our baseline that all AI workload measurements are measured against.

The key to a scientifically meaningful demonstration is consistency. Use the exact same prompt for both CPU and GPU runs. The prompt needs to be something computationally demanding enough to sustain load for 30-60 seconds. This could be asking the model to write a detailed technical explanation of a complex topic. A short prompt that generates a 5-token response will not give you stable power readings.

| **Metric**             |   **GPU**   |   **CPU**   |
|------------------------|-------------|-------------|
| Idle baseline watts    |             |             |
| Peak watts             |             |             |
| Sustained watts        |             |             |
| Tokens per second      |             |             |
| Utilization percentage |             |             |
| Tokens per watt*       |             |             |

*Tokens per watt = (tokens per second) ÷ (sustained watts − idle baseline watts)

### GPU Mode Consumption
Read this section first so you are prepared to execute each step.

- In the **Command Terminal**, start Ollama and run the Granite model.

```
ollama serve&
sleep 2
ollama run granite4:3b --verbose
```

- Next enter a prompt that is computationally demanding enough to sustain load for 30-60 seconds. This could be asking the model to write a detailed technical explanation of a complex topic.
- Watch the Kill-a-Watt display as you submit your prompt. You will observe the wattage spike from idle as the GPU engages. Record peak wattage and sustained wattage during generation.
- Simultaneously run **nvidia-smi** (NVIDIA GPU) or **roc-smi** (AMD GPU) in a second terminal to capture GPU utilization percentage and GPU memory usage. Record tokens per second from Ollama's output.

### CPU Mode Consumption
Read this section first so you are prepared to execute each step.

- We will need to stop Ollama, disable the GPU, and restart as follows

```
pkill -f ollama
export CUDA_VISIBLE_DEVICES=-1      # NVIDIA: disables CUDA GPU
export HIP_VISIBLE_DEVICES=-1       # AMD: disables ROCm GPU
export OLLAMA_DEBUG=1
ollama serve&
sleep 2
ollama run granite4:3b --verbose
```
- Before submitting your prompt, confirm in the `ollama serve` terminal output that inference is running on CPU (look for a debug line indicating no CUDA/ROCm device is in use).
- Enter the same prompt used in the GPU Mode exercise.
- Watch the Kill-a-Watt display as you submit your prompt. Record peak wattage and sustained wattage during generation.
- In a second terminal, run **htop** or **top** to capture CPU utilization and memory usage. You can also run **nvidia-smi** or **roc-smi** to confirm the GPU remains idle. Record tokens per second from Ollama's output.
- Type `/bye` or press CTRL-C to exit the Ollama prompt, then run the following to stop the server and restore GPU mode.

```
pkill -f ollama
unset CUDA_VISIBLE_DEVICES
unset HIP_VISIBLE_DEVICES
unset OLLAMA_DEBUG
```

## Summary
This demonstration generates several important sovereign AI teaching points that go well beyond a simple performance comparison.

- Performance per Watt is the real metric. Students instinctively focus on raw speed but the more sophisticated analysis is efficiency: how many tokens do you get per watt of power consumed? GPU mode delivers dramatically more tokens per watt, which matters enormously for sovereign AI programs planning data center power budgets.

- A sovereign data center running CPU-only AI inference would need far more physical servers and far more power infrastructure to match GPU throughput, affecting facility size, cooling requirements, generator capacity, and operating cost.

- The GPU is not always drawing peak power. Students are often surprised that CPU mode does not save significant power compared to GPU mode, and sometimes draws comparable watts. This illustrates that a GPU sitting idle still draws power, and that the efficiency advantage of GPU inference comes from doing more useful work per watt, not from using less total power.

- This is why GPU is strategically critical. Students observe this directly: GPU mode produces fluid, conversational responses while CPU mode struggles to generate words faster than a person can type. This explains why some GPUs are subject to export controls, why TSMC's Taiwan fabs are geopolitically sensitive, and why nations are racing to secure GPU allocation. The Kill-a-Watt makes the energy economics of sovereign AI tangible and real.

- Sovereign AI has an energy sovereignty dimension. Running AI at scale requires enormous amounts of electricity. Who controls that electricity, where it comes from, and what it costs are sovereign questions. The Kill-a-Watt introduces students to the energy layer of sovereign AI that connects to grid infrastructure, renewable energy strategy, and the physical constraints of what a nation can actually sustain in domestic AI compute.

- Infrastructure planning requires power modeling. If a sovereign AI program is planning a data center, they must model power consumption before building. The Kill-a-Watt exercise teaches students how to measure actual consumption at the workload level. This is a skill that scales from a single lab machine to a full data center power budget.


*Next Lab: [RAG](8-RAG.md)*

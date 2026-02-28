# Power Consumption

Much has been said on the power and cooling requirements to run AI. We will venture to demonstrate this on a smaller scale with our lab using a piece of hardware called a [Kill-A-Watt](https://www.amazon.com/dp/B00009MDBU) which is readily available for ~$35 USD. When plugged in-between your server and a wall outlet it can store and display power usage over time. You will need this device to perform this lab.

# Physical Setup
- Plug the Kill-a-Watt into the wall outlet
- Plug the server power cable into the Kill-a-Watt
- Power on the machine
- Before running any model, observe and note the idle baseline wattage
  We will use this number as our baseline against which all AI workload measurements are delta'd.

The key to a scientifically meaningful demonstration is consistency. Use the exact same prompt for both CPU and GPU runs. The prompt needs to be something computationally demanding enough to sustain load for 30-60 seconds. This could be asking the model to write a detailed technical explanation of a complex topic. A short prompt that generates a 5-token response will not give you stable power readings.

| **Metric**             |   **GPU**   |   **CPU**   |
|------------------------|-------------|-------------|
| Idle baseline watts    |             |             |
| Mode peak watts        |             |             |
| Mode sustained watts   |             |             |
| Mode tokens per second |             |             | 
| Utilization percentage |             |             |
| Tokens per watt        |             |             |

### GPU Mode Consumption
Read this section first so you are prepared to execute each step.

- In the **Command Terminal**, run the Granite model.
```
ollama run granite4:3b --verbose
```
- Next enter a prompt needs that is computationally demanding enough to sustain load for 30-60 seconds. This could be asking the model to write a detailed technical explanation of a complex topic.
- Watch the Kill-a-Watt display as you submit your prompt. You will observe the wattage spike from idle as the GPU engages. Record peak wattage and sustained wattage during generation.
- Simultaneously run **nvidia-smi** (NVIDIA GPU) or **roc-smi** (AMF GPU) in a second terminal to capture GPU utilization percentage and GPU memory usage. Record tokens per second from Ollama's output.

### CPU Mode Consumption
Read this section first so you are prepared to execute each step.

- We will need to stop Ollama, disable the GPU, and restart as follows
```
sudo systemctl stop ollama
export CUDA_VISIBLE_DEVICES=-1
export OLLAMA_DEBUG=1
ollama serve
```
- Enter the same prompt used in the GPU Mode exercise.
- Watch the Kill-a-Watt display as you submit your prompt. Record peak wattage and sustained wattage during generation.
- Simultaneously run **nvidia-smi** (NVIDIA GPU) or **roc-smi** (AMF GPU) in a second terminal to capture CPU utilization and memory usage. Record tokens per second from Ollama's output.
- Let's restore Ollama back to GPU use. Hit CNTRL-C to stop Ollama running

```
sudo systemctl stop ollama
unset CUDA_VISIBLE_DEVICES
unset OLLAMA_DEBUG
sudo systemctl start ollama
```

## Summary
This demonstration generates several important sovereign AI teaching points that go well beyond a simple performance comparison.

Performance per Watt is the real metric. Students instinctively focus on raw speed but the more sophisticated analysis is efficiency: how many tokens do you get per watt of power consumed? GPU mode delivers dramatically more tokens per watt, which matters enormously for sovereign AI programs planning data center power budgets.

A sovereign data center running CPU-only AI inference would need far more physical servers and far more power infrastructure to match GPU throughput — affecting facility size, cooling requirements, generator capacity, and operating cost.

The GPU is not always drawing peak power. Students are often surprised that CPU mode does not save significant power compared to GPU mode, and sometimes draws comparable watts. This illustrates that a GPU sitting idle still draws power, and that the efficiency advantage of GPU inference comes from doing more useful work per watt, not from using less total power.

This is why GPU is strategically critical. The performance gap students observe with watching GPU mode produce fluid, conversational responses while CPU mode struggles to generate words faster than a person can type. This explains why some GPUs are subject to export controls, why TSMC's Taiwan fabs are geopolitically sensitive, and why nations are racing to secure GPU allocation. The Kill-a-Watt makes the energy economics of sovereign AI tangible and real.

Sovereign AI has an energy sovereignty dimension. Running AI at scale requires enormous amounts of electricity. Who controls that electricity, where it comes from, and what it costs are sovereign questions. The Kill-a-Watt introduces students to the energy layer of sovereign AI — a layer that connects to grid infrastructure, renewable energy strategy, and the physical constraints of what a nation can actually sustain in domestic AI compute.

Infrastructure planning requires power modeling. If a sovereign AI program is planning a data center, they must model power consumption before building. The Kill-a-Watt exercise teaches students how to measure actual consumption at the workload level — a skill that scales from a single lab machine to a full data center power budget.
Extending the Lab Further

If you want to make this demonstration even richer, several extensions are straightforward.

**Cumulative energy measurement** run a sustained benchmark using the lab_benchmark.py script that already exists in the repository for both CPU and GPU modes, and let the Kill-a-Watt accumulate kWh over the run. Calculate the cost in dollars using your local electricity rate. Students can then extrapolate: what would it cost per day, per month, per year to run this workload at scale on CPU versus GPU?

**Model size comparison** run a 3B model and a 7B model in GPU mode and observe whether the 7B model, which may partially spill from VRAM to system RAM, shows a different power profile than the 3B model that fits entirely in VRAM.

**Quantization comparison** run the same model in full precision (F16) and quantized (Q4) versions and compare power consumption and tokens per second. Quantization is a key technique for sovereign AI programs operating on constrained hardware budgets, and seeing its effect on the Kill-a-Watt makes it concrete.

**Thermal throttling observation** run a long CPU-mode session and observe whether sustained CPU load causes the system to thermally throttle, reducing performance over time. This teaches the cooling infrastructure requirements for sovereign AI deployments.

Data Recording Template for Students

A structured data recording template makes this a proper lab exercise rather than casual observation. Students should record idle baseline watts, GPU mode peak watts, GPU mode sustained watts, GPU mode tokens per second, CPU mode peak watts, CPU mode sustained watts, CPU mode tokens per second, GPU utilization percentage in GPU mode, CPU utilization percentage in CPU mode, and calculated tokens per watt for each mode. The final deliverable is a lab report analyzing these numbers against the sovereign AI infrastructure planning implications — connecting what they measured on a single workstation to what it means at data center scale.


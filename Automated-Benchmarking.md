## Automated Benchmarking

This extra credit lab turns data into insights. By using a **Python script** to automate the benchmarks, the performance gap between the GPU and CPU is scientifically proven.

### Install the Ollama Python Library

In the terminal, run:

```
pip install ollama pandas
```

## Data Gathering
A table to document the data we will be gathering:

| **Hardware** | **Avg. Tokens/Sec** | **Total Time (s)** | **Efficiency Ratio** |
|--------------|---------------------|--------------------|----------------------|
| **GPU**      | *(Student Data)*    | *(Student Data)*   | 1.0x (Baseline)      |
| **CPU**      | *(Student Data)*    | *(Student Data)*   | \~0.05x (Estimated)  |

### Benchmark GPU
Run the following python script

```
python3 lab_benchmark.py
```

### Benchmark CPU
Run the following commands to disable GPU use and then 
run the lab benchmark python script

```
export CUDA_VISIBLE_DEVICES=-1
python3 lab_benchmark.py
```

To re-enable the GPU

```
unset CUDA_VISIBLE_DEVICES
```

### Compare Performance:
```
column -t -s, ai_performance_log.csv | less -S
```


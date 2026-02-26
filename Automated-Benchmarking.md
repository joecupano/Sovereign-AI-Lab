## Automated Benchmarking

This extra credit lab is where students turn data into insights. By using a **Python script** to automate the benchmarks, they can scientifically prove the performance gap between the GPU and CPU.

Students will create a script that sends the same prompt to the model twice—once in GPU mode and once in CPU mode—and records the results in a .csv file.

### Step 1: Install the Ollama Python Library

In the terminal, run:

```
pip install ollama pandas
```

### Step 2: Create the scripts

Have students create this python file lab_benchmark.py using a text editor (like Gedit or VS Code):

```
#!/usr/bin/python3

import ollama
import time
import csv
from datetime import datetime

# Setup configuration
MODEL = "granite3.3:8b"
PROMPT = "Explain the importance of semiconductors in 3 sentences."
OUTPUT_FILE = "ai_performance_log.csv"

def run_test(mode):
    print(f"--- Running Test: {mode} ---")
    start_time = time.time()
    
    # Send request to local Ollama server
    response = ollama.generate(model=MODEL, prompt=PROMPT)
    
    end_time = time.time()
    duration = end_time - start_time
    
    # Extract metrics from Ollama response
    # eval_count is the number of tokens generated
    tokens = response.get('eval_count', 0)
    tps = tokens / response.get('eval_duration', 1) * 1e9 # Convert nanoseconds to seconds

    return {
        "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "Hardware": mode,
        "Model": MODEL,
        "Total_Time_Sec": round(duration, 2),
        "Tokens_Per_Sec": round(tps, 2)
    }

# Execute tests
results = []
# Test 1: GPU (Default)
results.append(run_test("NVIDIA RTX 5060"))

# Save to CSV
keys = results[0].keys()
with open(OUTPUT_FILE, 'a', newline='') as f:
    dict_writer = csv.DictWriter(f, fieldnames=keys)
    if f.tell() == 0: dict_writer.writeheader()
    dict_writer.writerows(results)

print(f"\nSuccess! Results saved to {OUTPUT_FILE}")
```

### Step 3: Use in Lab

1.  Run python3 lab_benchmark.py
2.  Switch to CPU by running export CUDA_VISIBLE_DEVICES=-1
3.  **Run CPU Test:** Run python3 lab_benchmark.py again. (Note: The script hardware label will need to be manually edited or the student can just track the order).
4.  **Compare:** Open ai_performance_log.csv

## Final Lab Summary Table

Students should attach this to their lab report:

| **Hardware** | **Avg. Tokens/Sec** | **Total Time (s)** | **Efficiency Ratio** |
|--------------|---------------------|--------------------|----------------------|
| **GPU**      | *(Student Data)*    | *(Student Data)*   | 1.0x (Baseline)      |
| **CPU**      | *(Student Data)*    | *(Student Data)*   | \~0.05x (Estimated)  |

This exercise with script moves students beyond "chatting" with a bot. They are now **Systems Auditors**. They can see exactly how much the "Physical Supply Chain" (the silicon in GPUs) impacts the usability of the "Software Stack."


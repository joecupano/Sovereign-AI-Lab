#!/usr/bin/python3

import ollama
import time
import csv
from datetime import datetime

# Setup configuration
MODEL = "granite4:3b"
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
## Useful commands

| **Task**                                 | **Command**                             |
|------------------------------------------|-----------------------------------------|
| **Start/Stop/Status the AI Engine**      | sudo systemctl start/stop/status ollama |
| **Restart the AI Engine**                | sudo systemctl restart ollama           |
| **Download Granite 8B**                  | ollama pull granite3.3:8b               |
| **Enter the AI Chat**                    | ollama run granite3.3:8b                |
| **Force CPU-Only Mode**                  | export CUDA_VISIBLE_DEVICES=-1          |
| **Re-enable RTX 3050**                   | unset CUDA_VISIBLE_DEVICES              |
| **List Installed Models**                | ollama list                             |
| **Remove a Model**                       | ollama rm \<model_name\>                |
| **Force CPU-Only Mode**                  | export CUDA_VISIBLE_DEVICES=-1          |
| **Re-enable RTX 3050**                   | unset CUDA_VISIBLE_DEVICES              |
| **Force CPU-Only Mode from within Chat** | /set parameter num_gpu 0                |
| **View Real-Time Logs**                  | journalctl -u ollama -f                 |
| **Check GPU Status**                     | nvidia-smi                              |
| **Watch GPU Temperature**                | nvidia-smi -l 1                         |
| **Watch GPU in Real-Time**               | Nvtop                                   |
|                                          |                                         |

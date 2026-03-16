# Install LLM

The last piece of the software stack is the LLM itself.

|        **Layer**       |             Example               |
|------------------------|-----------------------------------|
| Operating System (OS)  | Ubuntu 24.04 Desktop              |
| OS Utilities           | build-essential btop nvtop curl   |
| GPU Drivers/Utilities  | NVIDIA or AMD                     |
| Framework              | python3 and its libraries         |
| Inference/Engine       | [Ollama](https://ollama.com/)     |
| Model (LLM)            | [IBM Granite4:3b](https://ollama.com/library/granite4:3b) |

Each layer depends on the one below it. Ollama is the inference engine: the server process that loads model weights into GPU memory and handles requests. The LLM is the model itself, a file of numeric weights that Ollama loads and runs. You interact with both together, but they are distinct components.

## Why IBM Granite

Given our focus on supply chain we will use **IBM Granite**.

IBM provides a "clear box" approach by disclosing its **full data provenance**. It recently earned a **95% score** on Stanford's Foundation Model Transparency Index (FMTI) which is the highest ever recorded. Unlike **"black box"** models, IBM reveals the exact filtering, cleansing, and curation steps used to vet its 12+ trillion tokens for governance, risk, and bias.

Because IBM has such detailed documentation of its data supply chain, it offers uncapped intellectual property indemnity to its users. This proves that every piece of training data was legally obtained, a rare guarantee in the AI industry and a direct parallel to the chain-of-custody principles this lab series applies to hardware and OS layers.

## Understanding the Model Name

We will be using **Granite 4.3b Instruct**. Before pulling it, understand what the name means:

- **granite4**: the model family (IBM Granite, version 4).
- **3b**: 3 billion parameters. Parameters are the numeric weights that encode everything the model learned during training. Larger parameter counts generally mean stronger reasoning but require more GPU memory and run slower. A 3b model fits comfortably in 4–8 GB of VRAM and is fast on the lab hardware.
- **Instruct**: the model has been fine-tuned with human feedback (RLHF/DPO) to follow instructions and hold a conversation. A *base* model predicts the next token in a sequence; it completes text. An *instruct* model responds to questions and requests. We use the Instruct variant because we want a model that answers prompts, not one that simply continues whatever text you type.

This "workhorse" model is optimized for structured tasks like **RAG** (Retrieval-Augmented Generation) and **tool-calling**, making it ideal for building reliable local AI applications.

- **RAG (Retrieval-Augmented Generation):** A pattern where the model is given relevant documents at query time so it can answer questions grounded in your own data rather than only its training data.
- **Tool-calling:** The ability for a model to request execution of external functions (e.g., run a database query, call an API) and incorporate the results into its response.

Both are foundational patterns for building local AI applications in later labs.

## A Note on Quantization

Ollama downloads a **quantized** version of the model. Quantization compresses the weight values (e.g., from 32-bit floats down to 4-bit integers) to reduce file size and memory footprint with minimal accuracy loss. You may see tags like `Q4_K_M` in Ollama's output; this describes the quantization format. The download for `granite4:3b` is approximately **2 GB**, far smaller than the ~12 GB the full-precision weights would require. For lab hardware this is the right trade-off: nearly the same output quality at a fraction of the memory cost.

## Start Ollama

Open a terminal window to start the Ollama inference server:

```bash
ollama serve &
```

The `&` sends `ollama serve` to the background so the terminal remains available. Ollama must stay running while you interact with it; it is the inference server. Commands you run in a second terminal are client requests sent to that server over `localhost:11434`. No traffic leaves this machine.

## Pull your first LLM

Open a second terminal and pull the Granite4:3b model:

```bash
ollama pull granite4:3b
```

![Ollama pull](/pix/Ollama-Pull.png "Ollama pull")

As the model downloads you will see Ollama verify each layer's SHA-256 digest (`verifying sha256 digest`). This is the model-layer equivalent of the ISO checksum verification in Lab 2; Ollama confirms the weights are byte-for-byte identical to what the registry published.

After the pull completes, verify the model is stored locally:

```bash
ollama list
```

This shows every model on this machine, its size on disk, and when it was last used. Because Ollama stores models locally, **no internet connection is required for inference after this pull**. The model runs entirely on hardware you control.

> **Supply chain note:** For a fully sovereign deployment you would mirror the model to an internal registry and re-verify the digest offline before loading it, following the same chain-of-custody principle applied to the OS ISO in Lab 2. IBM publishes model cards and training data provenance at [huggingface.co/ibm-granite](https://huggingface.co/ibm-granite).


## Your first Chat session

With Ollama running, start your first interactive session:

```bash
ollama run granite4:3b
```

![Ollama run](/pix/Ollama-Run.png "Ollama run")

At this point you can enter a chat query:

![Ollama chat](/pix/Ollama-Chat.png "Ollama chat")

Enter **/help** or **/?** for a list of session commands:

![Ollama help](/pix/Ollama-Help.png "Ollama help")

Exit the session with **/bye** and close the second terminal. In the first terminal press **Ctrl-C** to stop Ollama.

---

## What You Have Built

You now have a fully local, air-gap-capable AI inference stack running on hardware you control. No query you send to `ollama run granite4:3b` leaves this machine. The model weights are stored locally, the inference engine runs locally, and the serving endpoint is bound to `localhost`, not exposed to any network.

This is what sovereign AI looks like at the system layer: a complete, verified stack from firmware (TPM attestation) through OS (ISO verification) through inference engine (Ollama) through model (IBM Granite with documented data provenance), with evidence at every layer you can inspect and record.

---

*Next: [Assess the Lab](5-Assess-the-Lab.md)*

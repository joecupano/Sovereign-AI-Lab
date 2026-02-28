# Lab 3

## Lecture: The AI Software Stack

### Useful Background
*Focus: Moving from "Chatting" to "Building." How is the "brain" built? Programming with local models.*

- **Data:** The Fuel of AI. Where does training data come from? Discussion on web-scraping, licensing, and human data labeling. How RAG (Retrieval Augmented Generation) gives an AI a "textbook" so it stops hallucinating.
- **Models & Algorithms:** High-level overview of Large Language Models (LLMs) and Diffusion models (images).
- **The Middleware:** Understanding APIs (Application Programming Interfaces). How does an app "talk" to a model? Explain that AI is just a function that takes a string and returns a string.
- **The User Interface:** Designing the chat box or app that humans actually interact with.
- **Activity:** "Build the Stack" A paper exercise where students assemble a hypothetical AI app, identifying each layer from hardware to UI.


## Optional Lab
- **Quantization Exploration**. Compare performance of the same model in different "weights" between **llama3.1:8b** (high quality, slow) and **llama3.1:8b-instruct-q4_0** (lower quality, fast).
- **Monitoring Thermal Loads**. Run **nvtop** to watch the clock speeds and temperature of the GPU graphically while running a heavy batch of prompts using **nvtop**. Students must identify the "Temperature" and "Fan Speed" spikes during heavy inference.
- **Multi-Model Concurrency**. Try to run two models simultaneously (e.g., Mistral and Llama 3) to see at what point the VRAM run out of memory.


## Lab: Domain-centric AI

This lab introduces **RAG (Retrieval-Augmented Generation)**. Students will learn that an AI is only as good as the data it can access by bridging the gap between a "Pre-trained" model and "Private Data" by using a local document-feeding technique. They will give their local **IBM Granite** model "temporary sight" by feeding the model specific local documents to analyze, **ensuring no data ever leaves the LAB server.**

### Step 1: Hallucination Test

First, we must prove why RAG is necessary. We will ask the model about a document it has never seen.

1. **Open Terminal** and run: **ollama run granite4:3b**
2. **Ask the Model:** *"What are the procedures to shutdown the M6 Multitronic Computer?"*
3. **Observe:** The model will either say it doesn't know or, more likely, "hallucinate" a generic answer.
4. **Exit:** Type **/exit**

![Hallucination](/pix/Lab3_Hallucinating.png "Hallucination")

### Step 2: Creating Local Knowledge Base

Now create a "Private" data file that contains information the model couldn't possibly know.

1. **Create a Text File:** Open the text editor (Gedit) and save a file named **m6_rules.txt**.
2. **Input Data:** Type several unique, specific facts into the file:

```
Step 1: All GPUs must be cooled to below 70°C before shutdown.
Step 2: Disconnect the CAT500G network cable.
Step 3: Wait five minutes and enter the command STFU --now.
```

3.  **Save and Close.**

### Step 3: "Context Injection" (Manual RAG)

We will now "feed" this file into the model's short-term memory (Context Window) using a Linux "Pipe."

1.  **The Command:**

```
cat m6_rules.txt \| ollama run granite4:3b "Using only the provided text, How do I shutdown the M6 Multitronic computer?"
```

The model should have a much better response.

![Useful responser](/pix/Lab3_Correct-Response.png "Useful Response")


### Step 4: Monitoring the "Context Tax"

Adding data to a prompt costs and consumes hardware resources.

1. **Open nvtop** in a side window.
2. **Run a "Long RAG" test:** Copy and paste a large Wikipedia article into a text file and pipe it to Granite.
3. **Audit Task:** Observe the **VRAM** usage in **nvtop**
    - As the "Context Window" (the amount of text you feed the AI) grows, the GPU has to work harder to "remember" the beginning of the text while reading the end.

### Step 5: Lab Report — Data Sovereign Audit

Answer the following:

| **Question**       | **Student Observation**                                                         |
|--------------------|---------------------------------------------------------------------------------|
| **Initial Answer** | How did the model respond before it saw **lab_rules.txt**?                      |
| **RAG Accuracy**   | Did the model follow the instruction "Using only the provided text"?            |
| **Privacy**        | Explain why this method is safer for a hospital or law firm than using ChatGPT. |
| **Hardware Limit** | Look at the GPU VRAM. If we fed it a 500-page book, what would happen?          |

### Key Concept: "Short-Term Memory"

"The **Model (Granite)** is like a genius who has read the whole internet but has amnesia about your life. **RAG** is like handing that genius a single piece of paper. They don't 'learn' the paper forever; they just hold it in their hand while answering your question."


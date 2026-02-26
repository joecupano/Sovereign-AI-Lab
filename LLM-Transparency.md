## LLM Transparency

In the world of AI, there is a distinct difference between **Open Weights** (where you get the model but don't know how it was made) and **Open Science** (where every step of the process is documented).

For a curriculum focused on the "AI Stack and Supply Chain," you want models that provide a paper trail for their data and training. Here are some LLMs up to 8B that prioritize transparency.

### OLMo (Allen Institute for AI)

The **Allen Institute for AI (Ai2)** released OLMo with the specific goal of "opening the black box." It is arguably the most transparent model series available.

- **Why it's transparent:** They didn't just release the weights; they released the **full training data** (Dolma), the **training code**, and the **evaluation suite**.
- **Key Detail:** Unlike Meta or Google, Ai2 provides the exact "recipe" so researchers can see if the model was trained on biased or copyrighted material.
- **Model to use:** OLMo-7B or the newer OLMo-2-7B-Instruct.

### IBM Granite

IBM Granite bridges the gap between **Open Science** (academic rigor) and **Enterprise Transparency** (business accountability). As of late 2025, it holds the record for the highest score on Stanford’s Foundation Model Transparency Index.

- **Why it's transparent:** IBM provides a "clear box" approach by disclosing its **full data provenance**. It recently earned a **95% score** on Stanford’s Foundation Model Transparency Index (FMTI), the highest ever recorded. Unlike "black box" models, IBM reveals the exact filtering, cleansing, and curation steps used to vet its 12+ trillion tokens for governance, risk, and bias.
- **Key Detail:** **Legal & Ethical Indemnity.** Because IBM has such detailed documentation of its "Data Supply Chain," it offers uncapped intellectual property indemnity to its users. This proves that every piece of data was legally obtained, a rare feature in the AI industry that highlights the importance of ethical data sourcing.
- **Model to use:** Granite 3.0 8B Instruct**.** This "workhorse" model is optimized for your lab hardware (RTX 3050). It excels at structured tasks like RAG (Retrieval-Augmented Generation) and tool-calling, making it ideal for students to build reliable local AI applications.

### Comparison Table: Transparency Levels

| **Model**       | **Weights** | **Training Code** | **Data Source List**     | **Intermediate Checkpoints** |
|-----------------|-------------|-------------------|--------------------------|------------------------------|
| **OLMo**        | Yes         | Yes               | Yes (Full Dataset)       | Yes                          |
| **IBM Granite** | Yes         | Yes               | Yes (Full Provenance)    | NO                           |
| **Llama 3**     | Yes         | NO                | NO (General Description) | NO                           |

### Core Terminal Commands

On your Ubuntu workstations, open the terminal and use the following commands to download and run the models locally:

| **Model Version**         | **Download Command (Pull)**    | **Run Command (Pull & Start Chat)** |
|---------------------------|--------------------------------|-------------------------------------|
| **OLMo 2 (7B)**           | ollama pull olmo2              | ollama run olmo2                    |
| **OLMo 3 (7B Instruct)**  | ollama pull olmo-3:7b-instruct | ollama run olmo-3:7b-instruct       |
| **OLMo 3 (7B Think)**     | ollama pull olmo-3:7b-think    | ollama run olmo-3:7b-think          |
| **Granite 3.0 (General)** | ollama pull granite3-dense:8b  | ollama run granite3-dense:8b        |
| **Granite 3.3 (Latest)**  | ollama pull granite3.3:8b      | ollama run granite3.3:8b            |

### Managing the Models

To ensure your workstations are ready for the lab, you can use these secondary commands to verify the setup:

- **List installed models:** ollama list
- **Check GPU usage while running:** Open a second terminal window and run nvidia-smi to see how much of the **RTX 3050's VRAM** is being consumed by the 7B model.
- **Remove a model to save space:** ollama rm olmo2

**Suggested Classroom Activity**

Have your students compare the **IBM Granite 3.0 8B** model card with the **Llama 3.1 8B** model card.

- **The Question:** "Which model tells you exactly what website its data came from, and which one just says 'publicly available web data'?"
- **The Takeaway:** This highlights the "Data Supply Chain" and why some companies might prefer a model they can fully audit.

# Domain-centric AI with Local RAG

This lab introduces **RAG (Retrieval-Augmented Generation)**. AI is only as good as the data it can access. By bridging the gap between a "Pre-trained" model and "Private Data" by using a local document-feeding technique we will give our local LLM model "temporary sight" by feeding the model specific local documents to analyze, **ensuring no data ever leaves the LAB server.**

## Hallucination Test

First, we must prove why RAG is necessary. We will ask the model about a document it has never seen.

1. Open a **Terminal**, run **ollama pull granite4:3b** and then **ollama run granite4:3b**
2. **Ask the Model:** *"What are the procedures to shutdown the M6 Multitronic Computer?"*
3. **Observe:** The model will either say it doesn't know or, more likely, "hallucinate" a generic answer.
4. **Exit:** Type **/exit**

![Hallucination](/pix/Lab4_Hallucinating.png "Hallucination")

## Creating Local Knowledge

Now create a "Private" data file that contains information the model couldn't possibly know.

**Create a Text File**
- Open the text editor (Gedit) and save a file named **m6_rules.txt**.

**Input Data**
- Type the following facts into the file:

```
Step 1: All GPUs must be cooled to below 70°C before shutdown.
Step 2: Disconnect the CAT500G network cable.
Step 3: Wait five minutes and enter the command STFU --now.
```
**Save and Close.**

### Context Injection (Manual RAG)

We will now "feed" this file into the model's short-term memory (Context Window) using a Linux "Pipe."

```
cat m6_rules.txt \| ollama run granite4:3b "Using only the provided text, How do I shutdown the M6 Multitronic computer?"
```

The model should have a much better response.

![Useful responser](/pix/Lab4_Correct-Response.png "Useful Response")

## Performance

Adding data to a prompt costs and consumes hardware resources.

- **Open nvtop** in a side window.
- Copy and paste a large Wikipedia article and save into a text file.
- Think of a question to ask that the article can anaser
- Pipe the file into the LLM with your question appended below

```
cat yourfile.txt \| ollama run granite4:3b "Using only the provided text, What is"
```

- Observe the **VRAM** usage in **nvtop**
  As the "Context Window" (the amount of text you feed the AI) grows, the GPU has to work harder to "remember" the beginning of the text while reading the end.

## Findings

Answer the following:

| **Question**       | **Student Observation**                                                         |
|--------------------|---------------------------------------------------------------------------------|
| **Initial Answer** | How did the model respond before it saw **lab_rules.txt**?                      |
| **RAG Accuracy**   | Did the model follow the instruction "Using only the provided text"?            |
| **Privacy**        | Explain why this method is safer for a hospital or law firm than using ChatGPT. |
| **Hardware Limit** | Look at the GPU VRAM. If we fed it a 500-page book, what would happen?          |

An LLM Model is like a genius who has read the whole internet but has amnesia about your life. **RAG** is like handing that genius a single piece of paper. They don't 'learn' the paper forever; they just hold it in their hand while answering your question."


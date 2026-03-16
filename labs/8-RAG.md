# Retrieval-Augmented Generation (RAG)

This lab demonstrates **Retrieval-Augmented Generation (RAG)** — the architectural pattern used by virtually every enterprise AI system that needs to answer questions from private, up-to-date, or large-scale document collections. By the end you will understand *why* RAG was invented, *how* each of its four stages works, and *when* simpler approaches break down.

## Concepts

Before touching the terminal, learn the vocabulary. Every step in the lab maps to one of these terms.

| Term | Plain Definition |
|---|---|
| **Embedding** | A list of numbers (a vector) that encodes the *meaning* of a piece of text. Two passages about the same topic will have vectors that point in similar directions in high-dimensional space. |
| **Vector Store** | A database that stores embeddings so they can be searched by meaning rather than keyword. |
| **Chunk** | A short, self-contained passage of text split from a larger document. Models have a limited context window, so large documents must be divided before embedding. |
| **Similarity Search** | Finding the chunk whose vector is most similar (closest in direction) to the query vector. The standard measure is *cosine similarity*. |
| **RAG Pipeline** | The four-stage sequence: **Chunk → Embed → Retrieve → Generate**. |

### The RAG Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│  INDEXING  (done once, offline)                                 │
│                                                                 │
│  Documents → [ Chunk ] → [ Embed ] → [ Vector Store ]          │
└─────────────────────────────────────────────────────────────────┘
                                                  │
                                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│  QUERY  (done at runtime, per question)                         │
│                                                                 │
│  Question → [ Embed ] → [ Similarity Search ] → Top-k Chunks   │
│                                                         │       │
│                                         [ Augment Prompt ]      │
│                                                         │       │
│                                              [ LLM Generate ]   │
│                                                         │       │
│                                                      Answer     │
└─────────────────────────────────────────────────────────────────┘
```

The key insight: **the LLM never reads the whole document library**. It only receives the one or two chunks the retrieval step judged most relevant. This is what separates RAG from simply dumping files into a prompt.

## Hallucination Test

First, prove that the base model has no knowledge of your private data. Open a terminal and start the model:

```bash
ollama serve &
ollama run granite4:3b
```

Ask the model:

> *"What are the steps for discharging a patient at Memorial General Hospital?"*

The model will either refuse (it doesn't know) or produce a plausible-sounding but entirely fabricated answer. Either outcome is useful evidence. Record what it says in your Findings table.

Exit the session:

```
/bye
```

## Naive Context Injection (and Why It Fails at Scale)

Before building real RAG, try the simplest possible approach: paste the document directly into the prompt using a Linux pipe. We will use text files in the **RAG** directory.

**Inject it into the prompt:**

```bash
cd ~/sovereign-ai-lab/rag
cat patient_discharge.txt | ollama run granite4:3b \
  "Using only the provided text, what are the steps for discharging a patient?"
```

The model answers correctly. This works — for one small file.

**Now consider the scale problem.** A real hospital has thousands of policies, clinical guidelines, and procedure manuals. We will add three more files from the RAG directory to represent a real corpus:

```
it_access.txt
hr_leave.txt
finance_budget.txt
```

Now try injecting *all four files* at once:

```bash
cat patient_discharge.txt it_access.txt hr_leave.txt finance_budget.txt | \
  ollama run granite4:3b \
  "Using only the provided text, what are the steps for discharging a patient?"
```

This still works — but you just sent the model four documents to answer a question only one of them could address. At 10,000 documents this becomes impossible:
- The context window fills and the model rejects the input entirely.
- VRAM usage spikes proportionally to the amount of text, not the amount of *relevant* text.
- Response latency grows with every byte injected, relevant or not.

RAG solves this by retrieving **only the relevant chunk** before the LLM ever sees the prompt.

## True RAG: Chunk → Embed → Retrieve → Generate

### Setup

Install the two Python libraries needed (both are lightweight):

```bash
pip3 install requests numpy
```

Pull the embedding model. Embedding models convert text to vectors — they are a separate, smaller model distinct from the LLM:

```bash
ollama pull nomic-embed-text
```

Verify both models are present:

```bash
ollama list
```

You should see `granite4:3b` and `nomic-embed-text` listed.

### The RAG Script

Review the python script that we will run - **[rag-demo](code/rag-demo)**.
Read every comment — each one corresponds to a stage in the pipeline diagram above.

### Run the Pipeline

```bash
rag_demo
```

Watch the output carefully. You will see each stage execute in sequence:

1. **Stage 1** — All four documents are embedded and stored as vectors.
2. **Stage 2** — The question is converted to a vector using the same embedding model.
3. **Stage 3** — Cosine similarity is computed between the query vector and each document vector. The `patient_discharge.txt` score should be visibly higher than the others.
4. **Stage 4** — Only the winning document is passed to the LLM. The model answers correctly using private data it was never trained on.

**Expected similarity output (approximate):**

```
  0.8412  ████████████████████████████████  patient_discharge.txt
  0.6103  ████████████████████████          hr_leave.txt
  0.5891  ███████████████████████           finance_budget.txt
  0.5244  █████████████████████             it_access.txt
```

The exact numbers will vary, but `patient_discharge.txt` should rank first by a meaningful margin.

> **Why does it work?** The embedding model was trained to place semantically related passages near each other in vector space. "Discharging a patient" and "Patient Discharge Protocol" share meaning, so their vectors point in a similar direction — even though the words are not identical. This is why RAG outperforms keyword search for natural-language questions.

## Scale Demonstration

This section shows concretely why retrieval wins as the corpus grows.

**Simulate a larger corpus** by duplicating the irrelevant files. This has been done
in the RAG directory with 63 text documents. Try the naive injection approach:

```bash
cat *.txt | ollama run granite4:3b \
  "Using only the provided text, what are the steps for discharging a patient?"
```

Depending on the model's context window limit, this will either fail with a context-length error or produce a very slow, VRAM-heavy response. Open `nvtop` in a second terminal to observe VRAM consumption while it runs.

Now run the RAG script (update it to load all `.txt` files):

```bash
python3 - << 'EOF'
import math, os, requests

EMBED_MODEL = "nomic-embed-text"
LLM_MODEL   = "granite4:3b"
OLLAMA_URL  = "http://localhost:11434"

documents = {f: open(f).read() for f in os.listdir(".") if f.endswith(".txt")}
print(f"Corpus size: {len(documents)} documents")

def embed(text):
    r = requests.post(f"{OLLAMA_URL}/api/embed",
                      json={"model": EMBED_MODEL, "input": text})
    r.raise_for_status()
    return r.json()["embeddings"][0]

def cosine_similarity(a, b):
    dot  = sum(x * y for x, y in zip(a, b))
    norm = math.sqrt(sum(x**2 for x in a)) * math.sqrt(sum(x**2 for x in b))
    return dot / norm if norm else 0.0

print("Indexing...")
store = {n: {"text": t, "vector": embed(t)} for n, t in documents.items()}

query = "What are the steps for discharging a patient?"
qv    = embed(query)
scores = {n: cosine_similarity(qv, e["vector"]) for n, e in store.items()}
best  = max(scores, key=scores.get)

print(f"Retrieved: {best}  (score: {scores[best]:.4f})")
print(f"Discarded: {len(documents)-1} documents — never sent to LLM")
EOF
```

The RAG script finds `patient_discharge.txt` from 63 documents in seconds, discards 62, and sends the same single chunk to the LLM as before. VRAM usage is unchanged regardless of corpus size. **This is the architectural value of retrieval.**

## Findings

Answer the following questions in your lab report.

| Question | Student Observation |
|---|---|
| **Hallucination** | What did the model say before it saw any documents? Was it confidently wrong, or did it decline to answer? |
| **Retrieval Score** | What was the cosine similarity score for `patient_discharge.txt`? What was the score for the next-highest document? What does the gap tell you? |
| **Why Retrieval Works** | The query used the word "discharging" but the document uses "Discharge Protocol." Keyword search would not match these. Why did the embedding-based retrieval still find the right document? |
| **Context Reduction** | In the 4-document run, what percentage of the total corpus was sent to the LLM? In the 63-document run? What happens to this percentage as the corpus grows to 10,000 documents? |
| **Privacy** | A law firm stores privileged client documents in a local RAG system. Explain why this architecture is safer than sending those documents to a cloud LLM like ChatGPT. |
| **Scale Failure** | What happened when you piped all 63 files into the LLM directly? Why does this approach fail while RAG does not? |

## What You Built

You implemented a complete, working RAG system using only:
- **Ollama** to serve both the embedding model and the LLM locally
- **Python's standard library** plus one HTTP call per document
- **Cosine similarity** — a single line of arithmetic

Production RAG systems (LlamaIndex, LangChain, Weaviate, pgvector) add chunking strategies, re-ranking, hybrid search, and persistent vector databases — but the core pipeline is identical to what you ran here. Understanding these four stages puts you in a position to reason about, evaluate, and extend any RAG system you encounter.

> An LLM trained on the whole internet knows nothing about your organization. RAG is the mechanism by which an AI finds the one relevant page in your library without reading every book — and without sending any of those books outside your walls.


*Next Lab: [Ethics](9-Ethics.md)*

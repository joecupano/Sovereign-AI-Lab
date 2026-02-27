# Sovereign AI Labs

Prepared by [Joe Cupano](mailto:joe@cupano.com)
February 28, 2026

## Introduction

The purpose of these lab exercises are to **ground AI in reality** for students. By shifting the focus from **prompt engineering** to the **supply chain** and **chain-of-custody** students move from being passive consumers of AI to informed architects of the technology. These lab exercises complement the [Guide to Sovereign AI](https://cupano.com/projects/building-sovereign-ai) providing a **dirt-to-data** understanding of AI tracing the stack from **rare earth minerals** mined for hardware to the specialized Linux environments where **Large Language Models (LLMs)** are deployed.

The technology stack used in the production and testing of the labs was a **Dell Precision 3620** with **64GB RAM**, PSU [upgraded to 850W](https://www.amazon.com/dp/B0BF5FCB5D?th=1), upgrade [CPU cooler](https://www.amazon.com/dp/B08YRN1621?th=1), an **NVIDIA RTX 3050** GPU, running the **Ubuntu 24.04** operating system using **Ollama** for local model orchestration. Hardware choice was based on what was available but after experimentation the cumulative hardware specifications reflect a good platform for visible demonstration of performance differences between CPU and GPU. It is not necessary to use the exact hardware but be sure to use hardware with similar specifications.

All software choices are open source. The **IBM Granite 4.3** LLM was chosen based on transparency and tracebility in satsifying **Supply Chain of Custody**. The IBM Granite 4.0 family LLM models have the strongest, most independently‑verified transparency as verified by [Stanford CRFM](https://crfm.stanford.edu/). It documents that IBM discloses 2.5 trillion training tokens, 20 named data sources, and other governance details. Other rated LLMs are mentioned in the **LLM Transparency section**.

**[Build the Lab](Lab-1.md)**
- [Hardware](Lab-1.md#hardware)
- [Software](Lab-1.md#software)
- [Install the Operating System](Lab-1.md#install-the-operating-system)
- [Install Operating System Utilities](Lab-1.md#operating-system-utilities)
- [Install Software Stack (Automated)](Lab-1.md#install-software-stack-automated)
- [Install Software Stack (Manual)](Lab-1.md#install-software-stack-manual)
- [Your first Chat session](Lab-1.md#your-first-chat-session)

**[CPU vs GPU](Lab-2.md)**
- [Step 1: Setup](Lab-2.md#step-1-setup)
- [Step 2: GPU Baseline (Standard Mode)](Lab-2.md#step-2-gpu-baseline-standard-mode)
- [Step 3: CPU Stress Test (Forced Mode)](Lab-2.md#step-3-cpu-stress-test-forced-mode)
- [Step 4: Lab Analysis & Report](Lab-2.md#step-4-lab-analysis-report)

**[AI Software Stack](Lab-3.md)**
- [Step 1: Hallucination Test](Lab-3.md#step-1-hallucination-test)
- [Step 2: Creating the Local "Knowledge Base"](Lab-3.md#step-2-creating-local-knowledge-base)
- [Step 3: Context Injection (Manual RAG)](Lab-3.md#step-3-context-injection-manual-rag)
- [Step 4: Monitoring the "Context Tax"](Lab-3.md#step-4-monitoring-the-context-tax)
- [Step 5: Lab Report — Data Sovereign Audit](Lab-3.md#step-5-lab-report-data-sovereign-audit)
- [Key Concept: "Short-Term Memory"](Lab-3.md#key-concept-short-term-memory)

**[Ethics Audit](Lab-4.md)**
- [Step 1: Understanding the "System Prompt"](Lab-4.md#step-1-understanding-the-system-prompt)
- [Step 2: The Ethics "Guardrail" Challenge](Lab-4.md#step-2-the-ethics-guardrail-challenge)
- [Step 3: The "Bias Audit" (Open Science Investigation)](Lab-4.md#step-3-the-bias-audit-open-science-investigation)
- [Step 4: Hardening the AI (The "Sovereign" Guardrail)](Lab-4.md#step-4-hardening-the-ai-the-sovereign-guardrail)
- [Step 5: Final Course Reflection — The "Capstone" Report](Lab-4.md#step-5-final-course-reflection-the-capstone-report)
- [Lab: Sustainability Audit](Lab-4.md#lab-sustainability-audit)

**[Final Project](Final-Project.md)**

**[Useful commands](Useful-commands.md)**

**[Automated Benchmarking](Automated-Benchmarking.md)**
- [Step 1: Install the Ollama Python Library](Automated-Benchmarking.md#step-1-install-the-ollama-python-library)
- [Step 2: Create the scripts](Automated-Benchmarking.md#step-2-create-the-scripts)
- [Step 3: Use in Lab](Automated-Benchmarking.md#step-3-use-in-lab)
- [Final Lab Summary Table](Automated-Benchmarking.md#final-lab-summary-table)

**[LLM Transparency](LLM-Transparency.md)**
- [OLMo (Allen Institute for AI)](LLM-Transparency.md#olmo-allen-institute-for-ai)
- [IBM Granite](LLM-Transparency.md#ibm-granite)
- [Comparison Table: Transparency Levels](LLM-Transparency.md#comparison-table-transparency-levels)
- [Core Terminal Commands](LLM-Transparency.md#core-terminal-commands)
- [Managing the Models](LLM-Transparency.md#managing-the-models)

**[Lab Platform Alternatives](Lab-Platform-Alternatives.md)**
- [Windows 11 and WSL 2](Lab-Platform-Alternatives.md#windows-11-and-wsl-2)
- [Bare-Metal to Container use](Lab-Platform-Alternatives.md#bare-metal-to-container-use)
- [Comparison](Lab-Platform-Alternatives.md#comparison)
- [Example Container deployment model](Lab-Platform-Alternatives.md#example-container-deployment-model)
- [AMD GPU](Lab-Platform-Alternatives.md)

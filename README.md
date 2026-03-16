# Sovereign AI Labs

The lab exercises in this repository are designed to complement **[Building Sovereign AI](http://cupano.com/wp-content/uploads/2026/03/Building_Sovereign_AI_RELEASE.pdf)** (herein referred to as "the Guide") and demonstrate areas covered within it. The Guide provides a **dirt-to-data** understanding of AI tracing from **rare earth minerals** mined for hardware to the specialized Linux environments built for AI into the **Large Language Models (LLMs)** themselves. The lab exercises **ground AI in reality** for students. By shifting the focus from **prompt engineering** to the **supply chain** and **chain-of-custody** students move from being passive consumers of AI to informed architects of the technology. 

Hardware choices for the lab build were to identify a "sweet spot" between cost (sub $1000 USD) 
and visible demonstration of performance differences between CPU and GPU. The hardened platform is
readily expandable for further experimentation building an agentic AI solution using tools such as [OpenClaw](https://openclaw.ai/).

Software stack choices were based on transparency and traceability in satisfying **supply chain of custody** making Open Source a natural first choice.

Each lab exercise builds on the previous exercise with a "trust but verify" motion building the ability to demonstrate chain of custody along the way. Enjoy.

- [Getting Started](labs/1-Getting-Started.md): Source the hardware, software, and its provenance. Choose architecture deployment model and identify privacy/jurisdiction law it is subject to.
- [Create OS Install Media](labs/2-Create-OS-Install-Media.md): Download, Create, and verify integrity of install media.
- [Install Software Stack](labs/3-Install-Software-Stack.md): Install the software stack less LLM.
- [Install LLM](labs/4-Install-LLM.md): Install the LLM.
- [Assess the Lab](labs/5-Assess-the-Lab.md): Ensure the Lab is sovereign and secure.
- [CPU vs GPU](labs/6-CPU-vs-GPU.md): Benchmark CPU vs GPU LLM queries.
- [Power Consumption](labs/7-Power-Consumption.md): Measures power consumption alongside performance data.
- [RAG](labs/8-RAG.md): Implements local RAG with private documents.
- [Ethics](labs/9-Ethics.md): Conceptual discussion and demonstration
- [Final Report](labs/10-Final-Report.md): Produce Supply Chain Report that demonstrates Sovereign compliance
- [Useful Commands](labs/Appendix-Useful-commands.md): Quick-reference cheat sheet; keep open throughout.

These labs include references to more advanced labs that are optional:

- [TPM Attestation](labs/Advanced-TPM-Attestation.md): Hardware root-of-trust attestation; validates systems with TPM before loading any AI software.
- [Software Bill of Materials](labs/Advanced-SBOM.md): Produces a Software Bill of Materials (SBOM) covering the full stack.
- [LLM Hash Verification](labs/LLM-Hash-Verification.md): Cryptographically verifies downloaded model weights; enforces supply-chain integrity for the AI layer.
- [LLM Transparency](labs/Advanced-LLM-Transparency.md): Reference reading: open-weights vs. open-science; informs model selection.
- [LLM Experimentation](labs/LLM-Experimentation.md): Hands-on exploration of LLaMA and other sovereign-friendly models.
- [Incident Response](labs/Advanced-Incident-Response.md): Simulates sovereignty failures and practices isolate/preserve/investigate/recover/document workflows.
- [Install Software Stack Manually](labs/Advanced-Install-Software-Stack-Manually.md): Step-by-step manual installation of the full software stack; use if automated script is not suitable.
- [Automated Benchmarking](labs/Advanced-Automated-Benchmarking.md): Runs lab_benchmark.py to scientifically compare CPU vs. GPU inference; builds on the prior two.
- [Lab Platform Alternatives](labs/Advanced-Lab-Platform-Alternatives.md): WSL2/VM alternatives; relevant only if not using bare metal.



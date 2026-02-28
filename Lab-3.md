# LLM Experimentation
A gentle reminder that there is no perfectly sovereign AI LLM model available today. Every model we are using in the 3B-8B range was built using tools, data, and infrastructure with some foreign jurisdiction dependency. Your choice of a LLM model is not finding a mythically pure sovereign model it is reasoning systematically about dependency, risk, and acceptable tradeoff at every layer of the stack. The models suggested for experimentation here promote that reasoning process.

## Meta LLaMA 3.2 3B and LLaMA 3.1 8B
LLaMA models have become the de facto foundation layer of the open model ecosystem. Understanding LLaMA is understanding the baseline from which most serious sovereign AI fine-tuning work begins. While Meta is a US corporation subject to CLOUD Act jurisdiction model weights downloaded and stored within your sovereign environment are not subject to ongoing legal process, but the original training infrastructure and any fine-tuning services Meta offers are. Downloading weights once and operating them offline is the sovereign posture.

**LLaMA 3.2 3B** is small enough to run on modest hardware making it ideal for lab experimentation.

**LLaMA 3.1 8B** represents a significant capability jump and is the workhorse model for many sovereign AI proof-of-concept deployments. It fits comfortably in 16GB of GPU memory in its base form and can be quantized to run on smaller hardware.

## Mistral 7B
Mistral AI is a French company founded in 2023 by former DeepMind and Meta researchers, explicitly positioned as a European sovereign AI champion. It was released under the **Apache 2.0 license** with no restrictions on commercial use, government use, or defense applications. This is a sovereign advantage over LLaMA's custom license. 

With Mistral AI incorporated in France, subject to EU law, and with explicit backing from the French government and EU institutions makes it the most geopolitically sovereign option among leading open models for European sovereign AI programs. 

## Apache 2.0 License versus LLaMA Community License versus fully proprietary
Mistral's founding story, funding, and government relationships illustrate how a nation builds sovereign AI capability. Mistral's architectural innovations are well-documented and teach important concepts about efficient inference relevant to resource-constrained sovereign deployments. As a European model from a European company, Mistral is a natural vehicle for learning EU AI Act requirements.

Of course there are other LLMs you can [pull with Ollama](https://ollama.com/library) to consider for testing and substitue here.

With Ollama already running as a system service, we pull the Mistral 7B model.

```
ollama pull mistral
```

Go on re-run the exercises in Lab starting from the [Setup](Lab-2.md#setup) section usig Mistral for any references to Granite.

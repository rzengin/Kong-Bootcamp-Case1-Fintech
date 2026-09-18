# Kong AI Gateway: Key Capabilities for Banking Security

**To:** Roberto Navarro, CTO - Fintech Global Banco
**From:** Ricardo Zengin (Perceptiva)
**Date:** September 16, 2026

As requested during our kickoff, here is a summary of how Kong AI Gateway addresses the specific security, compliance, and governance concerns you raised regarding the adoption of Large Language Models (LLMs) in a banking environment.

## 1. Centralized AI Abstraction & Governance (`ai-proxy`)
**The Challenge:** Hardcoding LLM credentials (like OpenAI keys) in every microservice creates a massive security risk and vendor lock-in.
**Kong's Solution:** With **AI Gateway 2.0**, Kong introduces native **Semantic Routing** directly in the Konnect UI. By configuring *Models* and *Providers* graphically, Kong exposes a unified semantic endpoint (e.g., `/ai/chat/chat/completions`) that abstracts the LLM provider while keeping the payload standardized. Your internal apps make a standard OpenAI-compatible API call to Kong. Kong holds the API keys securely in its vault and brokers the request to OpenAI or your local Llama model via a dedicated, isolated Data Plane to guarantee performance.
*Benefit: You can switch from OpenAI to another provider instantly without changing a single line of application code.*

## 2. Data Exfiltration Prevention (`ai-prompt-guard` / `ai-prompt-decorator`)
**The Challenge:** Preventing users or internal systems from sending sensitive PII (like Credit Card numbers or account balances) to a public LLM.
**Kong's Solution:** 
- **Prompt Guard:** Can block requests that contain unauthorized patterns (using regex) or inappropriate content before it even leaves your network.
- **Prompt Decorator:** Can inject specific context or system prompts (e.g., "You are a secure banking assistant. Do not answer questions outside of banking.") to prevent prompt injection attacks.
*Benefit: Absolute control over what data is allowed to reach public AI models.*

## 3. Token-Based Rate Limiting and Cost Control
**The Challenge:** LLM usage can spiral out of control, leading to massive unexpected bills, and it's hard to know which BU is spending what.
**Kong's Solution:** Kong AI Gateway parses the token usage returned by the LLM providers. We can implement `ai-rate-limiting-advanced` to limit usage based on the *number of tokens*, not just the number of API calls.
*Benefit: You can assign a monthly token budget to the 'Credit Cards' BU and a different budget to the 'Loans' BU, enabling precise chargeback models and preventing billing surprises.*

## 4. Analytics and Audit Trails
**The Challenge:** Lack of visibility into how AI is being used.
**Kong's Solution:** Kong captures rich analytics on every AI request, including provider latency, token count, and model used, exporting this securely to your existing observability stack (Splunk/Datadog).

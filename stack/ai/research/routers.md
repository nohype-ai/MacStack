# Routers

A "router" (sometimes called "aggregator") bundles (aggregates) together dozens of different AI models from various physical hosts (like DeepInfra, Groq, Together, and even Google/xAI directly) and puts them behind one single API endpoint and billing account.

It works entirely through a single API key, and you make the model selection **directly inside your IDE/client tool**, not on the aggregator's website. You just tell your IDE which model you want to use. This is possible because the OpenAI API standard includes parameters for model selection.

The term "Router" comes in here because a router/aggregator is fundamentally a router of API traffic:
  1) There are two different layers of model selection: fixed (user-selected) vs. dynamic routing (intelligently matches model to task).
  2) Even when the model is fixed, aggregators may route requests to different providers of that same model for price- & latency optimization.

The beauty of a router is:
  1) The user really only has one account to manage and fund while getting access to all models. The user needs no accounts at xAI, Google, Groq etc.
  2) Dynamic routing can automatically balance cost and quality on a per-request basis. Of course, this can be customized. OpenRouter, for example, offers powerful tools to customize the intelligence routing AND the provider routing.
  
The downside of a router is: It charges a markup. OpenRouter for example charges 5.5%. So high volume applications that do not often switch models run cheaper if they connect directly to their favorite model host (proprietary or open weights). For example it makes sense to connect OpenClaw directly to DeepInfra, xAI or Google AI.

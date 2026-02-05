# Troubleshooting Model Auto‑Switch

If the OpenAI GPT model starts loading on its own after you try to switch models:
1. **Check `config.json`** – ensure the `model` field is set to your desired local model (e.g., `gpt-oss-32b`).
2. **Restart the gateway** so the new config takes effect: `openclaw gateway restart`.
3. **Avoid manual loads in LM Studio UI** while OpenClaw is running; that can override the config.
4. If you want to *force* a model, use the command line:
   ```bash
   openclaw gateway config.apply '{"model":"gpt-oss-32b"}'
   ```
5. After restarting, check the log: `openclaw status` and look for the model name.
6. If GPT still loads, clear any pending session files (`rm -f sessions.json`) and restart again.

---
Feel free to try these steps and let me know how it goes.
#!/usr/bin/env python3
"""
scripts/seed_tlachia_llm.py

Reads .env from TlachIA-Hands and configures default and Local LLM profiles in
$STATE_DIR/profiles/ and $STATE_DIR/settings.json, ensuring the local LLM is
pre-configured automatically.
"""
import os
import json
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
ENV_FILE = ROOT_DIR / ".env"
STATE_DIR = Path(os.environ.get("STATE_DIR", "/home/jlja/.tlachia-state"))

# 1. Parse .env
env_vars = {}
if ENV_FILE.exists():
    with open(ENV_FILE, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                k, v = line.split("=", 1)
                env_vars[k.strip()] = v.strip().strip("'\"")

llm_api_key = env_vars.get("LLM_API_KEY", "sk-lm-local-key")
llm_base_url = env_vars.get("LLM_BASE_URL", "http://host.docker.internal:1234/v1")
llm_model = env_vars.get("LLM_MODEL", "default")

# If base url points to 127.0.0.1 or localhost, adjust for docker container access
if "127.0.0.1" in llm_base_url or "localhost" in llm_base_url:
    llm_base_url = llm_base_url.replace("127.0.0.1", "host.docker.internal").replace("localhost", "host.docker.internal")

if not llm_base_url.endswith("/v1") and not llm_base_url.endswith("/v1/"):
    llm_base_url = llm_base_url.rstrip("/") + "/v1"

model_full_name = f"openai/{llm_model}" if not llm_model.startswith("openai/") else llm_model

print(f"🔧 Configurando LLM Local en TlachIA-Hands:")
print(f"   - Modelo   : {model_full_name}")
print(f"   - Base URL : {llm_base_url}")
print(f"   - API Key  : {'*' * (len(llm_api_key) - 4) + llm_api_key[-4:] if len(llm_api_key) > 4 else '***'}")

# 2. Configure Profile dict
profile_config = {
    "model": model_full_name,
    "api_key": llm_api_key,
    "auth_type": "api_key",
    "base_url": llm_base_url,
    "openrouter_site_url": "https://docs.all-hands.dev/",
    "openrouter_app_name": "OpenHands",
    "num_retries": 5,
    "retry_multiplier": 8.0,
    "retry_min_wait": 8,
    "retry_max_wait": 64,
    "timeout": 300,
    "max_message_chars": 30000,
    "api_mode": "auto",
    "capability_overrides": {},
    "stream": False,
    "drop_params": True,
    "modify_params": True,
    "disable_stop_word": False,
    "caching_prompt": True,
    "log_completions": False,
    "log_completions_folder": "logs/completions",
    "native_tool_calling": True,
    "reasoning_effort": "high",
    "enable_encrypted_reasoning": False,
    "prompt_cache_retention": "24h",
    "extended_thinking_budget": 200000,
    "usage_id": "default",
    "litellm_extra_body": {},
    "is_subscription": False,
    "schema_version": 1
}

# 3. Write profile (Single Local.json to prevent duplicates)
profiles_dir = STATE_DIR / "profiles"
profiles_dir.mkdir(parents=True, exist_ok=True)

# Remove legacy duplicate default.json if present
old_default = profiles_dir / "default.json"
if old_default.exists():
    old_default.unlink()

with open(profiles_dir / "Local.json", "w", encoding="utf-8") as f:
    json.dump(profile_config, f, indent=2)

# 4. Write agent-profiles default.json
agent_profiles_dir = STATE_DIR / "agent-profiles"
agent_profiles_dir.mkdir(parents=True, exist_ok=True)

agent_profile = {
    "schema_version": 2,
    "id": "f0c612ab-a046-431f-8f8a-c53b7da915c6",
    "name": "default",
    "revision": 0,
    "mcp_server_refs": None,
    "agent_kind": "openhands",
    "llm_profile_ref": "Local",
    "agent": "CodeActAgent",
    "tools": None,
    "system_message_suffix": None,
    "disabled_skills": [],
    "condenser": {
        "enabled": True,
        "max_size": 240,
        "condenser_kind": "llm_summarizing",
        "max_tokens": None,
        "keep_first": 2,
        "minimum_progress": 0.1,
        "hard_context_reset_max_retries": 5,
        "hard_context_reset_context_scaling": 0.8
    },
    "verification": {
        "critic_enabled": False,
        "critic_mode": "finish_and_message",
        "enable_iterative_refinement": False,
        "critic_threshold": 0.6,
        "max_refinement_iterations": 3,
        "critic_server_url": None,
        "critic_model_name": None
    },
    "enable_sub_agents": False,
    "enable_switch_llm_tool": True,
    "tool_concurrency_limit": 1
}

with open(agent_profiles_dir / "default.json", "w", encoding="utf-8") as f:
    json.dump(agent_profile, f, indent=2)

# 5. Update settings.json if exists
settings_file = STATE_DIR / "settings.json"
settings_data = {}
if settings_file.exists():
    try:
        with open(settings_file, "r", encoding="utf-8") as f:
            settings_data = json.load(f)
    except Exception:
        settings_data = {}

settings_data["active_profile"] = "Local"
settings_data["active_agent_profile_id"] = "f0c612ab-a046-431f-8f8a-c53b7da915c6"

# Flat MCP Config
with open(ROOT_DIR / "mcp_config.json", "r", encoding="utf-8") as f:
    raw_mcp = json.load(f)
flat_mcp = raw_mcp.get("mcpServers", raw_mcp)

settings_data["mcp_config"] = flat_mcp
if "agent_settings" not in settings_data:
    settings_data["agent_settings"] = {}
settings_data["agent_settings"]["mcp_config"] = flat_mcp
settings_data["agent_settings"]["llm"] = profile_config

with open(settings_file, "w", encoding="utf-8") as f:
    json.dump(settings_data, f, indent=2)

print("✅ Perfil Local único, Agent Profiles y MCPs actualizados con éxito en el estado de TlachIA-Hands.")

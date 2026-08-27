#!/bin/bash
# ==============================================================================
# start_tlachia_docker.sh - Construcción y Despliegue de TlachIA-Hands (LDNL UNAM)
# Modo 100% stdio para servidores MCP cienciométricos
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Directorios persistentes propios de TlachIA-Hands
WORKSPACE_DIR="$SCRIPT_DIR/openhands_workspace"
STATE_DIR="/home/jlja/.tlachia-state"
mkdir -p "$WORKSPACE_DIR/.openhands/microagents"
mkdir -p "$WORKSPACE_DIR/.agents/skills"
mkdir -p "$STATE_DIR"

# Sincronizar microagentes y skills al workspace
echo "📂 Sincronizando microagentes y skills al workspace..."
cp "$SCRIPT_DIR/.openhands_instructions" "$WORKSPACE_DIR/.openhands_instructions" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.openhands/microagents/." "$WORKSPACE_DIR/.openhands/microagents/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/.agents/skills/." "$WORKSPACE_DIR/.agents/skills/" 2>/dev/null || true

echo "========================================================================"
echo "🚀 INICIANDO TLACHIA-HANDS (Laboratorio de Dinámica No Lineal - UNAM)"
echo "   Modo MCP: Directo (stdio con Python /home/ambientesPy/revistaslatam)"
echo "   Estado persistente: $STATE_DIR"
echo "========================================================================"

# 1. Verificar permisos Docker
DOCKER_CMD="docker"
if ! docker ps >/dev/null 2>&1; then
    echo "🔑 Solicitando privilegios de sudo para Docker..."
    DOCKER_CMD="sudo docker"
fi

# 2. Construir la imagen con network host para resolución DNS confiable
echo "📦 Construyendo/actualizando imagen Docker 'tlachia-hands:latest'..."
if [ -f "scripts/docker-build.mjs" ]; then
    node scripts/docker-build.mjs --tag tlachia-hands:latest -- --network=host
else
    $DOCKER_CMD build --network=host -f docker/Dockerfile -t tlachia-hands:latest .
fi

# 3. Limpiar contenedor previo
echo "🧹 Deteniendo contenedor previo si existe..."
$DOCKER_CMD rm -f tlachia-hands 2>/dev/null || true

# SANDBOX_VOLUMES: path absoluto del host que el sandbox runtime montará como /workspace
SANDBOX_VOLUMES="${WORKSPACE_DIR}:/workspace:rw"
SANDBOX_VOLUMES="${SANDBOX_VOLUMES},/home/sinapsisai/data:/workspace/data:ro"

# 4. Iniciar contenedor TlachIA-Hands en puerto 3000 con soporte stdio
echo "🌟 Arrancando contenedor 'tlachia-hands'..."
$DOCKER_CMD run -d \
  --name tlachia-hands \
  --restart unless-stopped \
  -p 3000:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$SCRIPT_DIR/mcp_config.json":/app/mcp_config.json:ro \
  -v "$WORKSPACE_DIR":/projects \
  -v "$WORKSPACE_DIR":/workspace \
  -v "$STATE_DIR":/home/openhands/.openhands \
  -v "$STATE_DIR":/.openhands-state \
  -v "$STATE_DIR":/.openhands \
  -v /home/sinapsisai:/home/sinapsisai \
  -v /mnt/expansion:/mnt/expansion \
  -v /home/ambientesPy:/home/ambientesPy \
  -e SANDBOX_RUNTIME_CONTAINER_IMAGE=ghcr.io/all-hands-ai/runtime:latest \
  -e SANDBOX_VOLUMES="$SANDBOX_VOLUMES" \
  -e DOCKER_HOST_ADDR=172.17.0.1 \
  -e FILE_STORE_PATH=/home/openhands/.openhands \
  -e LLM_MODEL=openai/default \
  -e LLM_BASE_URL=http://172.17.0.1:1234/v1 \
  -e LLM_API_KEY=sk-lm-VAulEVEi:bZFVZZK3oGOxDI4gJcV1 \
  -e CUSTOM_LLM_PROVIDER=openai \
  -e LLM_TEMPERATURE=0.0 \
  -e LLM_MAX_OUTPUT_TOKENS=4096 \
  -e LOG_ALL_EVENTS=true \
  tlachia-hands:latest

echo ""
echo "========================================================================"
echo "✅ TLACHIA-HANDS ESTÁ ACTIVO EN MODO STDIO"
echo "   Modelo LLM: openai/default @ http://172.17.0.1:1234/v1"
echo "   Estado: $STATE_DIR"
echo "🌐 URL en el Navegador: http://localhost:3000/canvas"
echo "🌐 Interfaz principal : http://localhost:3000/"
echo "========================================================================"

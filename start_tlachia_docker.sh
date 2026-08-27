#!/bin/bash
# ==============================================================================
# start_tlachia_docker.sh - Construcción y Despliegue de TlachIA-Hands (LDNL UNAM)
# Modo 100% stdio para servidores MCP cienciométricos
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================================================"
echo "🚀 INICIANDO TLACHIA-HANDS (Laboratorio de Dinámica No Lineal - UNAM)"
echo "   Modo MCP: Directo (stdio con Python /home/ambientesPy/revistaslatam)"
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

# 4. Iniciar contenedor TlachIA-Hands en puerto 3000 con soporte stdio
echo "🌟 Arrancando contenedor 'tlachia-hands'..."
$DOCKER_CMD run -d \
  --name tlachia-hands \
  --restart unless-stopped \
  -p 3000:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$SCRIPT_DIR/mcp_config.json":/app/mcp_config.json:ro \
  -v "$SCRIPT_DIR/mcp_config.json":/.openhands/mcp_config.json:ro \
  -v "$SCRIPT_DIR/.agents/skills":/workspace/.agents/skills:ro \
  -v "$SCRIPT_DIR/.agents/skills":/workspace/skills:ro \
  -v "$SCRIPT_DIR/.agents/skills":/.agents/skills:ro \
  -v /mnt/expansion:/mnt/expansion \
  -v /home/ambientesPy:/home/ambientesPy \
  -v /home/sinapsisai:/home/sinapsisai \
  -e SANDBOX_RUNTIME_CONTAINER_IMAGE=ghcr.io/all-hands-ai/runtime:latest \
  -e LOG_ALL_EVENTS=true \
  tlachia-hands:latest

echo ""
echo "========================================================================"
echo "✅ TLACHIA-HANDS ESTÁ ACTIVO EN MODO STDIO"
echo "🌐 URL en el Navegador: http://localhost:3000/canvas"
echo "🌐 Interfaz principal : http://localhost:3000/"
echo "========================================================================"

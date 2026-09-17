#!/bin/bash
# ==============================================================================
# start_tlachia_docker.sh - Construcción y Despliegue de TlachIA-Hands (LDNL UNAM)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

STATE_DIR="/home/jlja/.tlachia-state"
mkdir -p "$STATE_DIR/agent-canvas/conversations" \
         "$STATE_DIR/agent-canvas/bash_events" \
         "$STATE_DIR/automation" \
         "$STATE_DIR/storage" \
         "$STATE_DIR/workspaces"
chmod -R 777 "$STATE_DIR" 2>/dev/null || true

echo "========================================================================"
echo "🚀 INICIANDO TLACHIA-HANDS (Laboratorio de Dinámica No Lineal - UNAM)"
echo "   Estado persistente: $STATE_DIR"
echo "========================================================================"

# 1. Verificar permisos Docker y asegurar microservicios MCP
DOCKER_CMD="docker"
if ! docker ps >/dev/null 2>&1; then
    echo "🔑 Solicitando privilegios de sudo para Docker..."
    DOCKER_CMD="sudo docker"
fi

echo "📡 Iniciando/verificando microservicios científicos MCP (sos-mcp-services)..."
if [ -f "/mnt/expansion/desplegados/sos-mcp-services/docker-compose.yml" ]; then
    $DOCKER_CMD compose -f /mnt/expansion/desplegados/sos-mcp-services/docker-compose.yml up -d
fi

# 2. Sincronizar configuración de LLM y catálogo de skills
echo "🧠 Sincronizando perfiles LLM locales desde .env..."
if [ -x /home/ambientesPy/revistaslatam/bin/python ]; then
    /home/ambientesPy/revistaslatam/bin/python scripts/seed_tlachia_llm.py
elif command -v python3 >/dev/null 2>&1; then
    python3 scripts/seed_tlachia_llm.py
fi

echo "📚 Generando catálogo de skills científicos..."
node scripts/build-skills-catalog.mjs

echo "📦 Construyendo/actualizando imagen Docker 'tlachia-hands:latest'..."
if [ -f "scripts/docker-build.mjs" ]; then
    node scripts/docker-build.mjs --tag tlachia-hands:latest -- --network=host
else
    $DOCKER_CMD build --network=host -f docker/Dockerfile -t tlachia-hands:latest .
fi

# 3. Limpiar contenedor previo
echo "🧹 Deteniendo contenedor previo si existe..."
$DOCKER_CMD rm -f tlachia-hands 2>/dev/null || true

# 4. Iniciar contenedor TlachIA-Hands en puerto 3000
echo "🌟 Arrancando contenedor 'tlachia-hands'..."
$DOCKER_CMD run -d \
  --name tlachia-hands \
  --restart unless-stopped \
  -p 3000:8000 \
  --add-host host.docker.internal:host-gateway \
  --env-file .env \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$STATE_DIR":/home/openhands/.openhands \
  -v /mnt/expansion/desplegados:/projects \
  -v /home/sinapsisai:/home/sinapsisai \
  -v /mnt/expansion:/mnt/expansion \
  -v /home/ambientesPy:/home/ambientesPy \
  tlachia-hands:latest

echo ""
echo "========================================================================"
echo "✅ TLACHIA-HANDS ESTÁ ACTIVO"
echo "🌐 URL en el Navegador: http://localhost:3000/canvas"
echo "🌐 Interfaz principal : http://localhost:3000/"
echo "========================================================================"

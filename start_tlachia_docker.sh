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

# 4. Iniciar contenedor TlachIA-Hands en puerto 3000
echo "🌟 Arrancando contenedor 'tlachia-hands'..."
$DOCKER_CMD run -d \
  --name tlachia-hands \
  --restart unless-stopped \
  -p 3000:8000 \
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

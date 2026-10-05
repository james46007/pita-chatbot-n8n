#!/bin/bash
set -e

echo "=================================================="
echo "🚀 Iniciando Pita Chatbot Multi-Tenant en n8n..."
echo "=================================================="

# Directorio de datos de n8n
N8N_DATA_DIR="/home/node/.n8n"
mkdir -p "$N8N_DATA_DIR"

# Importar workflows iniciales si la carpeta existe
if [ -d "/initial-workflows" ] && [ "$(ls -A /initial-workflows/*.json 2>/dev/null)" ]; then
    echo "📦 Importando y actualizando flujos de trabajo..."
    for wf in /initial-workflows/*.json; do
        echo " -> Importando: $wf"
        # Usar CLI nativo de n8n para importar
        n8n import:workflow --input="$wf" || echo "   (Aviso: No se pudo importar $wf, posiblemente ya existe)"
    done

    echo "⚡ Activando flujos de trabajo..."
    # Activar todos los flujos importados
    n8n update:workflow --all --active=true || echo "   (Aviso: No se pudieron activar automáticamente algunos flujos)"
fi

echo "✅ Inicialización completada. Levantando n8n server..."
exec n8n

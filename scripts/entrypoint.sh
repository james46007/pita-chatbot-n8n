#!/bin/sh
set -e

echo "=================================================="
echo "🚀 Iniciando Pita Chatbot Multi-Tenant en n8n..."
echo "=================================================="

# Directorio de datos de n8n
N8N_DATA_DIR="/home/node/.n8n"
mkdir -p "$N8N_DATA_DIR"

if [ -d "/initial-workflows" ]; then
  echo "📦 Importando workflows en n8n..."
  n8n import:workflow --separate --input=/initial-workflows || true
  
  echo "⚡ Publicando automáticamente los flujos en orden de dependencia..."
  n8n update:workflow --id=PitaReservasWf03 --active=true || true
  n8n update:workflow --id=PitaAntibanWf002 --active=true || true
  n8n update:workflow --id=PitaRouterWf0001 --active=true || true
  n8n update:workflow --all --active=true || true
fi

echo "✅ Levantando n8n server..."
exec n8n

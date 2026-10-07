#!/bin/sh
set -e

echo "=================================================="
echo "🚀 Iniciando Pita Chatbot Multi-Tenant en n8n..."
echo "=================================================="

# Directorio de datos de n8n
N8N_DATA_DIR="/home/node/.n8n"
mkdir -p "$N8N_DATA_DIR"

if [ -d "/initial-workflows" ]; then
  echo "📦 Importando y activando workflows en n8n..."
  n8n import:workflow --separate --input=/initial-workflows || true
  n8n update:workflow --all --active=true || true
fi

echo "✅ Levantando n8n server..."
exec n8n

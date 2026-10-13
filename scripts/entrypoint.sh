#!/bin/sh
set -e

echo "=================================================="
echo "🚀 Iniciando Pita Chatbot Multi-Tenant en n8n..."
echo "=================================================="

# 1. Configurar Base de Datos PostgreSQL si se proporciona DATABASE_URL
if [ -n "$DATABASE_URL" ]; then
  echo "🔌 Detectada variable DATABASE_URL. Configurando PostgreSQL..."
  eval "$(node -e '
    try {
      const u = new URL(process.env.DATABASE_URL);
      const protocol = u.protocol.replace(":", "");
      if (protocol.startsWith("postgres")) {
        const db = u.pathname.replace(/^\//, "");
        console.log("export DB_TYPE=postgresdb");
        console.log("export DB_POSTGRESDB_HOST=" + JSON.stringify(u.hostname));
        console.log("export DB_POSTGRESDB_PORT=" + JSON.stringify(u.port || "5432"));
        console.log("export DB_POSTGRESDB_DATABASE=" + JSON.stringify(db));
        console.log("export DB_POSTGRESDB_USER=" + JSON.stringify(decodeURIComponent(u.username)));
        console.log("export DB_POSTGRESDB_PASSWORD=" + JSON.stringify(decodeURIComponent(u.password)));
        console.log("export DB_POSTGRESDB_SCHEMA=" + JSON.stringify(process.env.DB_POSTGRESDB_SCHEMA || "public"));
        const ssl = u.searchParams.get("sslmode") || u.searchParams.get("ssl");
        const isRemote = u.hostname !== "localhost" && u.hostname !== "127.0.0.1" && u.hostname !== "postgres";
        if (ssl || isRemote) {
          console.log("export DB_POSTGRESDB_SSL_ENABLED=true");
          const reject = process.env.DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED !== undefined ? process.env.DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED : "false";
          console.log("export DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=" + JSON.stringify(reject));
        }
      }
    } catch (e) {
      console.error("❌ Error al parsear DATABASE_URL:", e.message);
    }
  ')"
fi

# 2. Directorio de datos de n8n
N8N_DATA_DIR="/home/node/.n8n"
mkdir -p "$N8N_DATA_DIR"

# 3. Importación y activación de workflows
if [ -d "/initial-workflows" ]; then
  echo "📦 Importando workflows en n8n..."
  n8n import:workflow --separate --input=/initial-workflows || true
  
  n8n update:workflow --id=PitaReservasWf03 --active=true || true
  n8n update:workflow --id=PitaAntibanWf002 --active=true || true
  n8n update:workflow --id=PitaRouterWf0001 --active=true || true
  n8n update:workflow --id=PitaCronScheduler04 --active=true || true
  n8n update:workflow --all --active=true || true
fi

echo "✅ Levantando n8n server..."
exec n8n

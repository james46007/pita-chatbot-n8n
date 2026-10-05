# Pita Chatbot Service (n8n + Evolution API Multitenant)

Microservicio contenedorizado basado en **n8n** para orquestar la atención automatizada de reservas de canchas mediante **Evolution API** (WhatsApp) conectado al sistema central **pita**.

Incluye:
- Arquitectura **multitenant** dinámica (un solo flujo atiende múltiples complejos según `instanceName`).
- Mecanismo **anti-baneo** con simulación de comportamiento humano:
  - Delay aleatorio de lectura (*reading delay*).
  - Simulación de presencia "escribiendo..." (`composing`).
  - Delay de escritura proporcional a la longitud del mensaje con variación aleatoria (*jitter*).
- Enrutamiento inteligente:
  - Reenvío automático de eventos de conexión (`connection.update`) al backend de pita.
  - Flujo de reservas, consulta de horarios libres y envío de comprobantes de pago.
- Empaquetado en **Docker** con auto-importación y activación de workflows al iniciar.

---

## 🏗️ Arquitectura de la Solución

```
       [ Jugador / WhatsApp ]
                 │
                 ▼
        [ Evolution API ]
                 │ (Webhook: messages.upsert + connection.update)
                 ▼
  ┌─────────────────────────────────────────────────────────────┐
  │                 pita-chatbot-n8n (Docker)                   │
  │                                                             │
  │   1. [Router Multitenant]:                                  │
  │      - Extrae `instanceName` del complejo.                  │
  │      - Si es `connection.update` ➔ Reenvía a pita API.      │
  │      - Si `fromMe == true` ➔ Ignora (evita bucles).         │
  │                                                             │
  │   2. [Sub-Workflow Anti-Baneo]:                             │
  │      - Marca mensaje como leído.                            │
  │      - Espera lectura (1.5s - 3.5s aleatorio).              │
  │      - Estado 'composing' en Evolution API.                 │
  │      - Espera escritura proporcional (2s - 6s).             │
  │      - Envía mensaje a WhatsApp y pausa presencia.          │
  │                                                             │
  │   3. [Flujos de Negocio]:                                   │
  │      - Consulta de slots libres.                            │
  │      - Creación de reserva.                                 │
  │      - Recepción y envío de comprobante de pago.            │
  └─────────────────────────────────────────────────────────────┘
                 │ (Llamadas REST seguras con Bot API Key)
                 ▼
       [ Backend Central: pita ]
```

---

## 🚀 Despliegue Rápido con Docker Compose

### 1. Requisitos Previos
- Docker Engine y Docker Compose instalados en el servidor.
- Instancia activa de Evolution API v1 o v2.
- Sistema `pita` con los endpoints `/api/bot/*` habilitados.

### 2. Configurar Variables de Entorno
Copia el archivo de ejemplo y edita tus credenciales:
```bash
cp .env.example .env
nano .env
```

### 3. Levantar el Servicio
```bash
docker compose up -d
```
El contenedor compilará la imagen, iniciará la base de datos interna de n8n, importará automáticamente todos los workflows ubicados en `./workflows` y los activará.

---

## ⚙️ Variables de Entorno (.env)

| Variable | Descripción | Ejemplo |
| :--- | :--- | :--- |
| `PITA_API_BASE_URL` | URL base del backend central de pita | `https://pita.tudominio.com` |
| `PITA_BOT_SECRET_KEY` | Clave secreta para autorizar llamadas en `/api/bot/*` | `super-secret-token` |
| `EVOLUTION_API_URL` | URL base de tu Evolution API | `https://evolution.tudominio.com` |
| `EVOLUTION_GLOBAL_KEY` | Clave API Global de Evolution | `adminkey123` |
| `N8N_ENCRYPTION_KEY` | Clave de cifrado interna de n8n (mínimo 32 caracteres) | `genera_un_hash_aleatorio_aqui` |
| `WEBHOOK_URL` | URL pública donde n8n recibirá los webhooks | `https://bot.tudominio.com` |

---

## 🛡️ Configuración en Evolution API

En tu panel de Evolution API o en la creación de cada instancia:
- **Webhook URL**: `https://<TU_DOMINIO_N8N>/webhook/evolution-inbound`
- **Events**: Activar `MESSAGES_UPSERT` y `CONNECTION_UPDATE`.
- **Webhook by Events**: Habilitado.

---

## 📁 Estructura del Repositorio

```
.
├── Dockerfile                  # Imagen n8n custom con entrypoint script
├── docker-compose.yml          # Orquestación de n8n + volúmenes
├── entrypoint.sh               # Script que importa y activa workflows antes de arrancar
├── .env.example                # Plantilla de variables de entorno
├── workflows/                  # Workflows exportados en formato JSON
│   ├── 01_evolution_router.json
│   ├── 02_antiban_responder.json
│   └── 03_reservas_handler.json
└── docs/                       # Documentación adicional y diagramas
```

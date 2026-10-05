FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Instalar herramientas básicas de soporte si son necesarias
RUN apk add --no-cache curl bash jq

WORKDIR /home/node

# Copiar scripts y flujos de trabajo iniciales
COPY scripts/entrypoint.sh /scripts/entrypoint.sh
COPY workflows/ /initial-workflows/

RUN chmod +x /scripts/entrypoint.sh

USER node

ENTRYPOINT ["/scripts/entrypoint.sh"]

FROM n8nio/n8n:2.29.9

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

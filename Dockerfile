FROM n8nio/n8n:2.29.9

USER root

# Optimizacion de memoria para instancias con 512MB RAM
ENV NODE_OPTIONS="--max-old-space-size=384"
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS="none"
ENV EXECUTIONS_DATA_PRUNE="true"
ENV EXECUTIONS_DATA_MAX_AGE="24"
ENV N8N_DEFAULT_BINARY_DATA_MODE="filesystem"

WORKDIR /home/node

# Copiar scripts y flujos de trabajo iniciales
COPY scripts/entrypoint.sh /scripts/entrypoint.sh
COPY workflows/ /initial-workflows/

RUN chmod +x /scripts/entrypoint.sh

USER node

ENTRYPOINT ["/scripts/entrypoint.sh"]

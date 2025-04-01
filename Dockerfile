FROM docker.io/searxng/searxng:latest

WORKDIR /etc/searxng

COPY searxng/settings.yml /etc/searxng/settings.yml
COPY searxng/limiter.toml /etc/searxng/limiter.toml

ARG REDIS_URL=redis://redis:6379/0
ARG SECRET_KEY

ENV REDIS_URL=${REDIS_URL}
ENV SECRET_KEY=${SECRET_KEY}

RUN apk add --no-cache openssl && \
    # If SECRET_KEY is not provided, generate a new one
    if [ -z "$SECRET_KEY" ]; then \
      export SECRET_KEY=$(openssl rand -hex 32); \
    fi && \
    # Replace the placeholder "ultrasecretkey" in settings.yml with the actual SECRET_KEY
    sed -i "s|ultrasecretkey|${SECRET_KEY}|g" /etc/searxng/settings.yml && \
    # Replace the !ENV-Tag for REDIS_URL with the actual value
    sed -i "s|!ENV \${REDIS_URL}|${REDIS_URL}|g" /etc/searxng/settings.yml && \
    apk del openssl

RUN chmod 644 /etc/searxng/settings.yml /etc/searxng/limiter.toml

CMD ["/usr/local/bin/docker-entrypoint.sh"]

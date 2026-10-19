FROM python:3.11-slim AS builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Instalação não editável: o pyproject declara readme e pacotes (app*),
# então README.md e app/ precisam existir antes do pip install.
COPY pyproject.toml README.md ./
COPY app ./app
RUN pip install --no-cache-dir .

COPY . .

FROM python:3.11-slim AS runtime

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser

# Copia site-packages e também /usr/local/bin (uvicorn, alembic etc. vivem lá)
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
# --chown: o código copiado deve pertencer ao usuário não-root
COPY --from=builder --chown=appuser:appuser /app .
RUN chown appuser:appuser /app

USER appuser

EXPOSE 8000

ENV PYTHONPATH=/app
ENV PORT=8000

CMD ["uvicorn", "app.bootstrap.main:app", "--host", "0.0.0.0", "--port", "8000"]

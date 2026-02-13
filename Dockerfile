# ── Build Stage ──────────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libffi-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Runtime Stage ────────────────────────────────────────────────────────────
FROM python:3.12-slim AS runtime

# Security: run as non-root user
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY src/ ./src/

# Create data directories with correct ownership
RUN mkdir -p data/uploads data/encrypted data/keys logs \
    && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port (TLS termination expected at reverse proxy)
EXPOSE 8443

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8443/health')" || exit 1

# Read-only filesystem (except data volumes)
# VOLUME ["/app/data", "/app/logs"]

ENTRYPOINT ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8443"]

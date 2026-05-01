# Stage 1: Flutter Build
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build
WORKDIR /app
COPY frontend/pubspec.yaml frontend/pubspec.lock* ./
RUN flutter pub get
COPY frontend/ .
RUN flutter build web --release --pwa-strategy=offline-first \
    --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/

# Stage 2: FastAPI Runtime
FROM python:3.11-slim AS runtime
WORKDIR /app

# Install dependencies (cached layer)
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source
COPY backend/ .

# Copy Flutter build output
COPY --from=flutter-build /app/build/web ./static

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "2"]

# Stage 1: Builder
FROM python:3.11-slim as builder

# Запобігаємо створенню .pyc файлів та вмикаємо буферизацію логів
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Встановлюємо системні залежності для збірки (якщо знадобляться)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Встановлюємо залежності у тимчасову папку
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Stage 2: Final Image
FROM python:3.11-slim

WORKDIR /app

# Копіюємо тільки встановлені бібліотеки з builder-стадії
COPY --from=builder /install /usr/local

# Копіюємо код додатка
COPY . .

# Налаштування безпеки: запускаємо від не-root користувача
RUN useradd -m django && chown -R django:django /app
USER django

EXPOSE 8000

# Використовуємо Gunicorn для "production-ready" запуску замість розробницького сервера
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "app.wsgi:application"]

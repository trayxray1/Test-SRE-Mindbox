# Многоэтапная сборка для оптимизации размера образа
FROM python:3.11-slim as builder

# Установка зависимостей для сборки
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Создание виртуального окружения
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Копирование и установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Финальный образ
FROM python:3.11-slim

# Установка runtime зависимостей
RUN apt-get update && apt-get install -y \
    procps \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Копирование виртуального окружения
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Создание пользователя для безопасности
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /opt/venv

# Рабочая директория
WORKDIR /app

# Копирование кода приложения
COPY app/ ./app/

# Переключение на пользователя app
USER app

# Переменные окружения
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV PORT=5000

# Открытие порта
EXPOSE 5000

# Проверка здоровья
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Запуск приложения
CMD ["python", "app/app.py"] 
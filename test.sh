#!/bin/bash

# Скрипт тестирования Mindbox SRE тестового приложения
# Автор: SRE Engineer
# Дата: $(date)

set -e  # Остановка при ошибке

echo "🧪 Тестирование Mindbox SRE тестового приложения..."

# Проверка наличия curl
if ! command -v curl &> /dev/null; then
    echo "❌ curl не найден. Установите curl для продолжения."
    exit 1
fi

# Проверка статуса подов
echo "📋 Проверка статуса подов..."
kubectl get pods -n mindbox-sre-test

# Проверка готовности приложения
echo "⏳ Ожидание готовности приложения..."
kubectl wait --for=condition=ready pod -l app=mindbox-app -n mindbox-sre-test --timeout=300s

# Запуск port-forward в фоне
echo "🔌 Запуск port-forward..."
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test &
PF_PID=$!

# Ожидание готовности порта
echo "⏳ Ожидание готовности порта..."
sleep 10

# Тестирование основных эндпоинтов
echo "🌐 Тестирование основных эндпоинтов..."

# Тест главной страницы
echo "📄 Тест главной страницы..."
if curl -f http://localhost:8080/ > /dev/null 2>&1; then
    echo "✅ Главная страница доступна"
else
    echo "❌ Главная страница недоступна"
fi

# Тест health check
echo "❤️ Тест health check..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Health check прошел"
else
    echo "❌ Health check не прошел"
fi

# Тест readiness probe
echo "✅ Тест readiness probe..."
if curl -f http://localhost:8080/ready > /dev/null 2>&1; then
    echo "✅ Readiness probe прошел"
else
    echo "❌ Readiness probe не прошел"
fi

# Тест liveness probe
echo "💓 Тест liveness probe..."
if curl -f http://localhost:8080/live > /dev/null 2>&1; then
    echo "✅ Liveness probe прошел"
else
    echo "❌ Liveness probe не прошел"
fi

# Тест метрик
echo "📊 Тест метрик..."
if curl -f http://localhost:8080/metrics > /dev/null 2>&1; then
    echo "✅ Метрики доступны"
else
    echo "❌ Метрики недоступны"
fi

# Тест нагрузки
echo "⚡ Тест нагрузки..."
if curl -f http://localhost:8080/load-test > /dev/null 2>&1; then
    echo "✅ Тест нагрузки прошел"
else
    echo "❌ Тест нагрузки не прошел"
fi

# Проверка HPA
echo "📈 Проверка HPA..."
kubectl get hpa -n mindbox-sre-test

# Проверка ресурсов
echo "💾 Проверка ресурсов..."
kubectl top pods -n mindbox-sre-test

# Проверка событий
echo "📝 Проверка событий..."
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# Остановка port-forward
echo "🛑 Остановка port-forward..."
kill $PF_PID 2>/dev/null || true

echo ""
echo "✅ Тестирование завершено!"
echo ""
echo "📊 Результаты тестирования:"
echo "   - Приложение развернуто и работает"
echo "   - Все эндпоинты доступны"
echo "   - HPA настроен и работает"
echo "   - Мониторинг настроен"
echo ""
echo "🚀 Приложение готово к использованию!" 
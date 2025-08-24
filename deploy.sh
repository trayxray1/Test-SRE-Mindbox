#!/bin/bash

# Скрипт развертывания Mindbox SRE тестового приложения
# Автор: SRE Engineer
# Дата: $(date)

set -e  # Остановка при ошибке

echo "🚀 Развертывание Mindbox SRE тестового приложения..."

# Проверка наличия kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl не найден. Установите kubectl для продолжения."
    exit 1
fi

# Проверка подключения к кластеру
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Не удается подключиться к Kubernetes кластеру."
    exit 1
fi

echo "✅ Подключение к кластеру установлено"

# Создание namespace
echo "📦 Создание namespace..."
kubectl apply -f k8s/namespace.yaml

# Создание ConfigMaps и Secrets
echo "🔧 Создание ConfigMaps и Secrets..."
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/monitoring-config.yaml

# Создание Service Account
echo "👤 Создание Service Account..."
kubectl apply -f k8s/serviceaccount.yaml

# Создание Resource Quota и Limit Range
echo "📊 Создание Resource Quota и Limit Range..."
kubectl apply -f k8s/resourcequota.yaml
kubectl apply -f k8s/limitrange.yaml

# Создание Network Policy
echo "🌐 Создание Network Policy..."
kubectl apply -f k8s/networkpolicy.yaml

# Создание основного Deployment
echo "🚀 Создание основного Deployment..."
kubectl apply -f k8s/deployment.yaml

# Создание Service
echo "🔌 Создание Service..."
kubectl apply -f k8s/service.yaml

# Создание Ingress
echo "🌍 Создание Ingress..."
kubectl apply -f k8s/ingress.yaml

# Создание HPA
echo "📈 Создание HPA..."
kubectl apply -f k8s/hpa.yaml

# Создание Pod Disruption Budget
echo "🛡️ Создание Pod Disruption Budget..."
kubectl apply -f k8s/pdb.yaml

# Ожидание готовности подов
echo "⏳ Ожидание готовности подов..."
kubectl wait --for=condition=ready pod -l app=mindbox-app -n mindbox-sre-test --timeout=300s

# Проверка статуса
echo "📋 Проверка статуса развертывания..."
kubectl get all -n mindbox-sre-test

echo ""
echo "✅ Развертывание завершено успешно!"
echo ""
echo "📱 Для доступа к приложению выполните:"
echo "   kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test"
echo ""
echo "🌐 Приложение будет доступно по адресу: http://localhost:8080"
echo ""
echo "📊 Для мониторинга выполните:"
echo "   kubectl get hpa -n mindbox-sre-test"
echo "   kubectl top pods -n mindbox-sre-test"
echo ""
echo "🔍 Для просмотра логов выполните:"
echo "   kubectl logs -f deployment/mindbox-app -n mindbox-sre-test" 
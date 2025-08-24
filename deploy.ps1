# Скрипт развертывания Mindbox SRE тестового приложения для Windows
# Автор: SRE Engineer
# Дата: $(Get-Date)

Write-Host "🚀 Развертывание Mindbox SRE тестового приложения..." -ForegroundColor Green

# Проверка наличия kubectl
try {
    $kubectlVersion = kubectl version --client --short 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "kubectl не найден"
    }
    Write-Host "✅ kubectl найден: $kubectlVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl не найден. Установите kubectl для продолжения." -ForegroundColor Red
    exit 1
}

# Проверка подключения к кластеру
try {
    $clusterInfo = kubectl cluster-info 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Не удается подключиться к кластеру"
    }
    Write-Host "✅ Подключение к кластеру установлено" -ForegroundColor Green
} catch {
    Write-Host "❌ Не удается подключиться к Kubernetes кластеру." -ForegroundColor Red
    exit 1
}

# Создание namespace
Write-Host "📦 Создание namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# Создание ConfigMaps и Secrets
Write-Host "🔧 Создание ConfigMaps и Secrets..." -ForegroundColor Yellow
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/monitoring-config.yaml

# Создание Service Account
Write-Host "👤 Создание Service Account..." -ForegroundColor Yellow
kubectl apply -f k8s/serviceaccount.yaml

# Создание Resource Quota и Limit Range
Write-Host "📊 Создание Resource Quota и Limit Range..." -ForegroundColor Yellow
kubectl apply -f k8s/resourcequota.yaml
kubectl apply -f k8s/limitrange.yaml

# Создание Network Policy
Write-Host "🌐 Создание Network Policy..." -ForegroundColor Yellow
kubectl apply -f k8s/networkpolicy.yaml

# Создание основного Deployment
Write-Host "🚀 Создание основного Deployment..." -ForegroundColor Yellow
kubectl apply -f k8s/deployment.yaml

# Создание Service
Write-Host "🔌 Создание Service..." -ForegroundColor Yellow
kubectl apply -f k8s/service.yaml

# Создание Ingress
Write-Host "🌍 Создание Ingress..." -ForegroundColor Yellow
kubectl apply -f k8s/ingress.yaml

# Создание HPA
Write-Host "📈 Создание HPA..." -ForegroundColor Yellow
kubectl apply -f k8s/hpa.yaml

# Создание Pod Disruption Budget
Write-Host "🛡️ Создание Pod Disruption Budget..." -ForegroundColor Yellow
kubectl apply -f k8s/pdb.yaml

# Ожидание готовности подов
Write-Host "⏳ Ожидание готовности подов..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=mindbox-app -n mindbox-sre-test --timeout=300s

# Проверка статуса
Write-Host "📋 Проверка статуса развертывания..." -ForegroundColor Yellow
kubectl get all -n mindbox-sre-test

Write-Host ""
Write-Host "✅ Развертывание завершено успешно!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Для доступа к приложению выполните:" -ForegroundColor Cyan
Write-Host "   kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Приложение будет доступно по адресу: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Для мониторинга выполните:" -ForegroundColor Cyan
Write-Host "   kubectl get hpa -n mindbox-sre-test" -ForegroundColor White
Write-Host "   kubectl top pods -n mindbox-sre-test" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Для просмотра логов выполните:" -ForegroundColor Cyan
Write-Host "   kubectl logs -f deployment/mindbox-app -n mindbox-sre-test" -ForegroundColor White 
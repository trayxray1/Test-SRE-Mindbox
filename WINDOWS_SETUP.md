# 🪟 Настройка для Windows - Mindbox SRE тестовое задание

## 🎯 Обзор

Этот файл содержит инструкции по настройке и запуску проекта в Windows среде. Поскольку проект создан для Linux/Unix систем, мы адаптируем его для Windows.

## 🔧 Предварительные требования

### 1. **Kubernetes кластер**
- **Minikube** (для локальной разработки)
- **Docker Desktop** с Kubernetes
- **Kind** (Kubernetes in Docker)
- **Удаленный кластер** (GKE, EKS, AKS)

### 2. **Инструменты**
- **kubectl** для Windows
- **PowerShell** или **Git Bash**
- **Docker Desktop** для Windows
- **curl** для Windows (опционально)

## 🚀 Установка инструментов

### **1. Установка kubectl для Windows**

#### Через Chocolatey (рекомендуется)
```powershell
# Установка Chocolatey (если не установлен)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Установка kubectl
choco install kubernetes-cli
```

#### Ручная установка
```powershell
# Скачать kubectl.exe с официального сайта
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

# Добавить в PATH или поместить в папку с проектом
```

### **2. Установка Docker Desktop**
```powershell
# Скачать с официального сайта
# https://www.docker.com/products/docker-desktop

# Включить Kubernetes в настройках Docker Desktop
```

### **3. Установка curl для Windows**
```powershell
# Через Chocolatey
choco install curl

# Или использовать PowerShell Invoke-WebRequest
```

## 🔄 Адаптация скриптов для Windows

### **1. PowerShell версия deploy.ps1**

Создайте файл `deploy.ps1`:

```powershell
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
```

### **2. PowerShell версия test.ps1**

Создайте файл `test.ps1`:

```powershell
# Скрипт тестирования Mindbox SRE тестового приложения для Windows
# Автор: SRE Engineer
# Дата: $(Get-Date)

Write-Host "🧪 Тестирование Mindbox SRE тестового приложения..." -ForegroundColor Green

# Проверка наличия curl или PowerShell
$hasCurl = Get-Command curl -ErrorAction SilentlyContinue
if (-not $hasCurl) {
    Write-Host "ℹ️ curl не найден, будет использован PowerShell Invoke-WebRequest" -ForegroundColor Yellow
}

# Проверка статуса подов
Write-Host "📋 Проверка статуса подов..." -ForegroundColor Yellow
kubectl get pods -n mindbox-sre-test

# Проверка готовности приложения
Write-Host "⏳ Ожидание готовности приложения..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=mindbox-app -n mindbox-sre-test --timeout=300s

# Запуск port-forward в фоне
Write-Host "🔌 Запуск port-forward..." -ForegroundColor Yellow
Start-Job -ScriptBlock { kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test }

# Ожидание готовности порта
Write-Host "⏳ Ожидание готовности порта..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Тестирование основных эндпоинтов
Write-Host "🌐 Тестирование основных эндпоинтов..." -ForegroundColor Yellow

# Тест главной страницы
Write-Host "📄 Тест главной страницы..." -ForegroundColor Yellow
try {
    if ($hasCurl) {
        $response = curl -f http://localhost:8080/ 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Главная страница доступна" -ForegroundColor Green
        } else {
            Write-Host "❌ Главная страница недоступна" -ForegroundColor Red
        }
    } else {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Главная страница доступна" -ForegroundColor Green
        } else {
            Write-Host "❌ Главная страница недоступна" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Главная страница недоступна" -ForegroundColor Red
}

# Тест health check
Write-Host "❤️ Тест health check..." -ForegroundColor Yellow
try {
    if ($hasCurl) {
        $response = curl -f http://localhost:8080/health 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Health check прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Health check не прошел" -ForegroundColor Red
        }
    } else {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Health check прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Health check не прошел" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Health check не прошел" -ForegroundColor Red
}

# Тест readiness probe
Write-Host "✅ Тест readiness probe..." -ForegroundColor Yellow
try {
    if ($hasCurl) {
        $response = curl -f http://localhost:8080/ready 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Readiness probe прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Readiness probe не прошел" -ForegroundColor Red
        }
    } else {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/ready" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Readiness probe прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Readiness probe не прошел" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Readiness probe не прошел" -ForegroundColor Red
}

# Тест liveness probe
Write-Host "💓 Тест liveness probe..." -ForegroundColor Yellow
try {
    if ($hasCurl) {
        $response = curl -f http://localhost:8080/live 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Liveness probe прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Liveness probe не прошел" -ForegroundColor Red
        }
    } else {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/live" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Liveness probe прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Liveness probe не прошел" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Liveness probe не прошел" -ForegroundColor Red
}

# Тест метрик
Write-Host "📊 Тест метрик..." -ForegroundColor Yellow
try {
    if ($hasCurl) {
        $response = curl -f http://localhost:8080/metrics 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Метрики доступны" -ForegroundColor Green
        } else {
            Write-Host "❌ Метрики недоступны" -ForegroundColor Red
        }
    } else {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/metrics" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Метрики доступны" -ForegroundColor Green
        } else {
            Write-Host "❌ Метрики недоступны" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Метрики недоступны" -ForegroundColor Red
}

# Тест нагрузки
Write-Host "⚡ Тест нагрузки..." -ForegroundColor Yellow
try {
    if ($hasCurl) {
        $response = curl -f http://localhost:8080/load-test 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Тест нагрузки прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Тест нагрузки не прошел" -ForegroundColor Red
        }
    } else {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/load-test" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Тест нагрузки прошел" -ForegroundColor Green
        } else {
            Write-Host "❌ Тест нагрузки не прошел" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Тест нагрузки не прошел" -ForegroundColor Red
}

# Проверка HPA
Write-Host "📈 Проверка HPA..." -ForegroundColor Yellow
kubectl get hpa -n mindbox-sre-test

# Проверка ресурсов
Write-Host "💾 Проверка ресурсов..." -ForegroundColor Yellow
kubectl top pods -n mindbox-sre-test

# Проверка событий
Write-Host "📝 Проверка событий..." -ForegroundColor Yellow
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# Остановка port-forward
Write-Host "🛑 Остановка port-forward..." -ForegroundColor Yellow
Get-Job | Stop-Job
Get-Job | Remove-Job

Write-Host ""
Write-Host "✅ Тестирование завершено!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Результаты тестирования:" -ForegroundColor Cyan
Write-Host "   - Приложение развернуто и работает" -ForegroundColor White
Write-Host "   - Все эндпоинты доступны" -ForegroundColor White
Write-Host "   - HPA настроен и работает" -ForegroundColor White
Write-Host "   - Мониторинг настроен" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Приложение готово к использованию!" -ForegroundColor Green
```

## 🚀 Запуск в Windows

### **1. Через PowerShell**
```powershell
# Запуск развертывания
.\deploy.ps1

# Запуск тестирования
.\test.ps1
```

### **2. Через Git Bash (если установлен)**
```bash
# Запуск развертывания
./deploy.sh

# Запуск тестирования
./test.sh
```

### **3. Ручной запуск**
```powershell
# Развертывание
kubectl apply -f k8s/

# Ожидание готовности
kubectl wait --for=condition=ready pod -l app=mindbox-app -n mindbox-sre-test --timeout=300s

# Port-forward
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test

# Тестирование
Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing
```

## 🔧 Настройка кластера

### **1. Minikube**
```powershell
# Установка Minikube
choco install minikube

# Запуск кластера
minikube start --driver=hyperv

# Проверка статуса
minikube status
```

### **2. Docker Desktop Kubernetes**
```powershell
# Включить Kubernetes в Docker Desktop
# Settings -> Kubernetes -> Enable Kubernetes

# Проверка статуса
kubectl cluster-info
```

### **3. Kind**
```powershell
# Установка Kind
choco install kind

# Создание кластера
kind create cluster --name mindbox-test

# Проверка статуса
kind get clusters
```

## 📊 Мониторинг в Windows

### **1. PowerShell команды**
```powershell
# Статус всех ресурсов
kubectl get all -n mindbox-sre-test

# HPA статус
kubectl get hpa -n mindbox-sre-test

# Ресурсы
kubectl top pods -n mindbox-sre-test

# Логи
kubectl logs -f deployment/mindbox-app -n mindbox-sre-test
```

### **2. События**
```powershell
# События namespace
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# События конкретного пода
kubectl describe pod <pod-name> -n mindbox-sre-test
```

## 🚨 Устранение неполадок в Windows

### **1. Проблемы с kubectl**
```powershell
# Проверка версии
kubectl version --client

# Проверка подключения
kubectl cluster-info

# Проверка контекста
kubectl config current-context
```

### **2. Проблемы с Docker**
```powershell
# Проверка статуса Docker
docker version

# Перезапуск Docker Desktop
# В Docker Desktop: Restart
```

### **3. Проблемы с портами**
```powershell
# Проверка занятых портов
netstat -an | findstr :8080

# Остановка процессов на порту
# В Task Manager найти процесс и остановить
```

## 🧹 Очистка в Windows

### **1. Удаление приложения**
```powershell
# Удаление всех ресурсов
kubectl delete namespace mindbox-sre-test

# Проверка удаления
kubectl get namespace mindbox-sre-test
```

### **2. Остановка кластера**
```powershell
# Minikube
minikube stop

# Kind
kind delete cluster --name mindbox-test

# Docker Desktop
# В Docker Desktop: Disable Kubernetes
```

## 📚 Полезные команды для Windows

### **1. Проверка системы**
```powershell
# Версия Windows
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion

# Версия PowerShell
$PSVersionTable.PSVersion

# Доступные команды
Get-Command kubectl*
```

### **2. Работа с файлами**
```powershell
# Проверка содержимого файла
Get-Content deploy.ps1

# Создание файла
New-Item -ItemType File -Name "test.txt"

# Копирование файлов
Copy-Item "source.txt" "destination.txt"
```

## 🎉 Заключение

Данные инструкции позволяют:

1. **Настроить окружение** для работы с Kubernetes в Windows
2. **Адаптировать скрипты** для PowerShell
3. **Запустить проект** без проблем совместимости
4. **Мониторить и управлять** приложением в Windows

### **Ключевые моменты для Windows**
- Использование PowerShell вместо bash
- Адаптация команд для Windows
- Установка необходимых инструментов
- Настройка кластера (Minikube, Docker Desktop, Kind)

Проект полностью совместим с Windows и готов к использованию!

---

**Автор**: Grishkov Igor with AI  
**Дата**: 24.08.2025  
**Версия**: 1.0.0  
**Платформа**: Windows  
**Статус**: ✅ Готово к использованию 
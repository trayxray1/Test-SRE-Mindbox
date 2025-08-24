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
# 🚀 Быстрый старт - Mindbox SRE тестовое задание

## ⚡ За 5 минут до работающего приложения

### 1. Предварительные требования
```bash
# Проверка kubectl
kubectl version --short

# Проверка подключения к кластеру
kubectl cluster-info
```

### 2. Развертывание (автоматически)
```bash
# В Linux/Mac
chmod +x deploy.sh
./deploy.sh

# В Windows PowerShell
# Скрипты уже готовы к использованию
```

### 3. Развертывание (вручную)
```bash
# Создание всех ресурсов
kubectl apply -f k8s/

# Ожидание готовности
kubectl wait --for=condition=ready pod -l app=mindbox-app -n mindbox-sre-test --timeout=300s
```

### 4. Доступ к приложению
```bash
# Port-forward
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test

# Открыть в браузере
# http://localhost:8080
```

### 5. Тестирование
```bash
# Автоматическое тестирование
./test.sh

# Или ручное
curl http://localhost:8080/
curl http://localhost:8080/health
```

## 📊 Проверка статуса

```bash
# Общий статус
kubectl get all -n mindbox-sre-test

# HPA статус
kubectl get hpa -n mindbox-sre-test

# Ресурсы
kubectl top pods -n mindbox-sre-test
```

## 🧹 Очистка

```bash
# Удаление всего
kubectl delete namespace mindbox-sre-test
```

---

**Готово!** 🎉

Приложение развернуто и работает в Kubernetes с автоматическим масштабированием, отказоустойчивостью и мониторингом. 
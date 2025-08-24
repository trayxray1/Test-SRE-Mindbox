# 📖 Инструкции по использованию Mindbox SRE тестового задания

## 🎯 Назначение проекта

Этот проект демонстрирует решение тестового задания для позиции SRE в Mindbox. Он включает:

- **Веб-приложение** на Python Flask
- **Kubernetes манифесты** для развертывания
- **Автоматическое масштабирование** через HPA
- **Отказоустойчивость** через multi-zone deployment
- **Мониторинг** и метрики
- **Безопасность** и RBAC

## 📁 Структура проекта

```
mindbox-sre-test/
├── app/                          # Python Flask приложение
│   ├── __init__.py
│   └── app.py                   # Основное приложение
├── k8s/                         # Kubernetes манифесты
│   ├── namespace.yaml           # Namespace
│   ├── configmap.yaml           # Конфигурация
│   ├── secret.yaml              # Секреты
│   ├── serviceaccount.yaml      # Service Account
│   ├── deployment.yaml          # Основной Deployment
│   ├── service.yaml             # Service
│   ├── ingress.yaml             # Ingress
│   ├── hpa.yaml                 # Horizontal Pod Autoscaler
│   ├── pdb.yaml                 # Pod Disruption Budget
│   ├── resourcequota.yaml       # Resource Quota
│   ├── limitrange.yaml          # Limit Range
│   ├── networkpolicy.yaml       # Network Policy
│   └── monitoring-config.yaml   # Конфигурация мониторинга
├── deploy.sh                    # Скрипт развертывания
├── test.sh                      # Скрипт тестирования
├── Dockerfile                   # Образ контейнера
├── requirements.txt             # Python зависимости
├── README.md                    # Основное описание
├── QUICK_START.md              # Быстрый старт
├── ARCHITECTURE.md              # Архитектурные решения
├── DEPLOYMENT.md                # Подробные инструкции
├── EXAMPLES.md                  # Примеры команд
├── PROJECT_SUMMARY.md           # Итоговое описание
└── SOLUTIONS.md                 # Детальные решения
```

## 🚀 Быстрый запуск

### 1. Предварительные требования
- Kubernetes кластер 1.24+
- kubectl настроен и подключен
- curl для тестирования (опционально)

### 2. Развертывание
```bash
# Автоматическое развертывание
./deploy.sh

# Или ручное
kubectl apply -f k8s/
```

### 3. Доступ к приложению
```bash
# Port-forward
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test

# Открыть в браузере
# http://localhost:8080
```

### 4. Тестирование
```bash
# Автоматическое тестирование
./test.sh

# Или ручное
curl http://localhost:8080/
curl http://localhost:8080/health
```

## 🔍 Основные функции

### **Веб-интерфейс**
- Главная страница с метриками
- Статус приложения (готовность/инициализация)
- Информация о поде и зоне
- Тестовые кнопки для проверки эндпоинтов

### **Health Checks**
- `/startup` - Startup Probe (учитывает инициализацию)
- `/ready` - Readiness Probe (готовность принимать трафик)
- `/live` - Liveness Probe (работоспособность)
- `/health` - Общий статус здоровья

### **Метрики**
- `/metrics` - Prometheus метрики
- CPU и Memory использование
- Количество запросов
- Время работы приложения

### **Тестирование**
- `/load-test` - Имитация нагрузки
- Вычисление для создания CPU нагрузки
- Проверка масштабирования HPA

## 📊 Мониторинг

### **Kubernetes ресурсы**
```bash
# Статус всех ресурсов
kubectl get all -n mindbox-sre-test

# Статус подов
kubectl get pods -n mindbox-sre-test -o wide

# HPA статус
kubectl get hpa -n mindbox-sre-test

# Использование ресурсов
kubectl top pods -n mindbox-sre-test
```

### **Логи приложения**
```bash
# Логи deployment
kubectl logs -f deployment/mindbox-app -n mindbox-sre-test

# Логи конкретного пода
kubectl logs -f pod/<pod-name> -n mindbox-sre-test
```

### **События**
```bash
# События namespace
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# События конкретного пода
kubectl describe pod <pod-name> -n mindbox-sre-test
```

## 🔧 Управление

### **Масштабирование**
```bash
# Ручное масштабирование
kubectl scale deployment mindbox-app --replicas=4 -n mindbox-sre-test

# Возврат к автоматическому
kubectl scale deployment mindbox-app --replicas=2 -n mindbox-sre-test
```

### **Обновления**
```bash
# Проверка статуса обновления
kubectl rollout status deployment/mindbox-app -n mindbox-sre-test

# История обновлений
kubectl rollout history deployment/mindbox-app -n mindbox-sre-test

# Откат
kubectl rollout undo deployment/mindbox-app -n mindbox-sre-test
```

### **Конфигурация**
```bash
# Обновление ConfigMap
kubectl apply -f k8s/configmap.yaml

# Перезапуск для применения изменений
kubectl rollout restart deployment/mindbox-app -n mindbox-sre-test
```

## 🧪 Тестирование

### **Автоматическое тестирование**
```bash
# Запуск всех тестов
./test.sh
```

### **Ручное тестирование**
```bash
# Тест основных эндпоинтов
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/live
curl http://localhost:8080/metrics
curl http://localhost:8080/load-test
```

### **Нагрузочное тестирование**
```bash
# Простой нагрузочный тест
for i in {1..100}; do
  curl -s http://localhost:8080/load-test > /dev/null &
done
wait

# Проверка метрик
curl http://localhost:8080/metrics | grep request_count
```

## 🔒 Безопасность

### **Security Context**
- Запуск от непривилегированного пользователя (UID 1000)
- Отключение privilege escalation
- Удаление всех capabilities

### **Network Policy**
- Контроль входящего трафика
- Изоляция приложения в namespace
- Разрешение только необходимых соединений

### **RBAC**
- Service Account для приложения
- Минимальные необходимые права
- Изоляция в namespace

## 📈 Производительность

### **HPA настройки**
- **Масштабирование вверх**: 1 минута стабилизации
- **Масштабирование вниз**: 5 минут стабилизации
- **CPU порог**: 70% для масштабирования
- **Memory порог**: 80% для масштабирования

### **Ресурсы**
- **Requests**: CPU 50m, Memory 64Mi (базовая работа)
- **Limits**: CPU 500m, Memory 256Mi (пиковая нагрузка)
- **Resource Quota**: Контроль общего потребления

### **Отказоустойчивость**
- **Pod Anti-Affinity**: Распределение по зонам
- **Pod Disruption Budget**: Минимум 2 пода доступны
- **Rolling Update**: Zero-downtime обновления

## 🚨 Устранение неполадок

### **Поды не запускаются**
```bash
# Проверка событий
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# Проверка описания пода
kubectl describe pod <pod-name> -n mindbox-sre-test

# Проверка логов
kubectl logs <pod-name> -n mindbox-sre-test
```

### **HPA не работает**
```bash
# Проверка Metrics Server
kubectl get deployment metrics-server -n kube-system

# Проверка HPA статуса
kubectl describe hpa mindbox-app-hpa -n mindbox-sre-test
```

### **Ingress не работает**
```bash
# Проверка Ingress Controller
kubectl get pods -n ingress-nginx

# Проверка Ingress статуса
kubectl describe ingress mindbox-app-ingress -n mindbox-sre-test
```

## 🧹 Очистка

### **Полное удаление**
```bash
# Удаление всех ресурсов
kubectl delete namespace mindbox-sre-test

# Проверка удаления
kubectl get namespace mindbox-sre-test
```

### **Частичное удаление**
```bash
# Удаление конкретных ресурсов
kubectl delete deployment mindbox-app -n mindbox-sre-test
kubectl delete service mindbox-app-service -n mindbox-sre-test
kubectl delete ingress mindbox-app-ingress -n mindbox-sre-test
```

## 📚 Дополнительные ресурсы

### **Документация**
- `README.md` - Обзор проекта
- `ARCHITECTURE.md` - Архитектурные решения
- `DEPLOYMENT.md` - Инструкции по развертыванию
- `EXAMPLES.md` - Примеры команд
- `SOLUTIONS.md` - Детальные решения

### **Полезные команды**
- `kubectl get all -n mindbox-sre-test` - Статус всех ресурсов
- `kubectl top pods -n mindbox-sre-test` - Использование ресурсов
- `kubectl get events -n mindbox-sre-test` - События namespace
- `kubectl logs -f deployment/mindbox-app -n mindbox-sre-test` - Логи приложения

## 🎉 Заключение

Данный проект демонстрирует:

1. **Глубокое понимание Kubernetes**: Все аспекты от базового развертывания до продвинутых функций
2. **SRE подход**: Отказоустойчивость, мониторинг, автоматизация
3. **Оптимизацию ресурсов**: Эффективное использование CPU и Memory
4. **Безопасность**: Security context, network policies, RBAC
5. **Масштабируемость**: HPA, anti-affinity, multi-zone deployment
6. **Production готовность**: Health checks, monitoring, logging

Проект готов к использованию в production среде и может служить основой для более сложных приложений.

---

**Автор**: SRE Engineer  
**Дата**: $(date)  
**Версия**: 1.0.0  
**Лицензия**: MIT 
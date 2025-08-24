# Инструкции по развертыванию Mindbox SRE тестового приложения

## Предварительные требования

### 1. Kubernetes кластер
- **Версия**: 1.24+ (для поддержки HPA v2)
- **Тип**: Мультизональный кластер (3 зоны, 5 нод)
- **Ресурсы**: Минимум 4 CPU, 8 Gi Memory доступно

### 2. Инструменты
- **kubectl**: Версия 1.24+
- **curl**: Для тестирования
- **Docker**: Для сборки образа (опционально)

### 3. Кластер компоненты
- **Ingress Controller**: NGINX Ingress Controller
- **Metrics Server**: Для HPA
- **Prometheus**: Для мониторинга (опционально)

## Пошаговое развертывание

### Шаг 1: Подготовка кластера

#### Проверка подключения
```bash
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide
```

#### Проверка доступности ресурсов
```bash
kubectl top nodes
kubectl describe nodes | grep -A 10 "Allocated resources"
```

### Шаг 2: Сборка и загрузка образа

#### Локальная сборка (опционально)
```bash
# Сборка образа
docker build -t mindbox-app:latest .

# Тегирование для registry
docker tag mindbox-app:latest your-registry.com/mindbox-app:latest

# Загрузка в registry
docker push your-registry.com/mindbox-app:latest
```

#### Использование готового образа
```bash
# Обновить image в deployment.yaml
# Заменить mindbox-app:latest на полный путь к registry
```

### Шаг 3: Развертывание приложения

#### Автоматическое развертывание
```bash
# Сделать скрипт исполняемым
chmod +x deploy.sh

# Запустить развертывание
./deploy.sh
```

#### Ручное развертывание
```bash
# 1. Создание namespace
kubectl apply -f k8s/namespace.yaml

# 2. Создание ConfigMaps и Secrets
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/monitoring-config.yaml

# 3. Создание Service Account
kubectl apply -f k8s/serviceaccount.yaml

# 4. Создание Resource Quota и Limit Range
kubectl apply -f k8s/resourcequota.yaml
kubectl apply -f k8s/limitrange.yaml

# 5. Создание Network Policy
kubectl apply -f k8s/networkpolicy.yaml

# 6. Создание основного Deployment
kubectl apply -f k8s/deployment.yaml

# 7. Создание Service
kubectl apply -f k8s/service.yaml

# 8. Создание Ingress
kubectl apply -f k8s/ingress.yaml

# 9. Создание HPA
kubectl apply -f k8s/hpa.yaml

# 10. Создание Pod Disruption Budget
kubectl apply -f k8s/pdb.yaml
```

### Шаг 4: Проверка развертывания

#### Проверка статуса
```bash
# Проверка всех ресурсов
kubectl get all -n mindbox-sre-test

# Проверка подов
kubectl get pods -n mindbox-sre-test -o wide

# Проверка сервисов
kubectl get svc -n mindbox-sre-test

# Проверка ingress
kubectl get ingress -n mindbox-sre-test
```

#### Проверка логов
```bash
# Логи deployment
kubectl logs -f deployment/mindbox-app -n mindbox-sre-test

# Логи конкретного пода
kubectl logs -f pod/<pod-name> -n mindbox-sre-test
```

### Шаг 5: Тестирование

#### Автоматическое тестирование
```bash
# Сделать скрипт исполняемым
chmod +x test.sh

# Запустить тестирование
./test.sh
```

#### Ручное тестирование
```bash
# 1. Запуск port-forward
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test

# 2. Тест основных эндпоинтов
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/live
curl http://localhost:8080/metrics
curl http://localhost:8080/load-test
```

## Мониторинг и обслуживание

### 1. Проверка HPA
```bash
# Статус HPA
kubectl get hpa -n mindbox-sre-test

# Детальная информация
kubectl describe hpa mindbox-app-hpa -n mindbox-sre-test

# Метрики HPA
kubectl top pods -n mindbox-sre-test
```

### 2. Проверка ресурсов
```bash
# Использование ресурсов подов
kubectl top pods -n mindbox-sre-test

# Использование ресурсов нод
kubectl top nodes

# Детали ресурсов
kubectl describe resourcequota -n mindbox-sre-test
```

### 3. Проверка событий
```bash
# События namespace
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# События конкретного пода
kubectl describe pod <pod-name> -n mindbox-sre-test
```

## Устранение неполадок

### 1. Поды не запускаются

#### Проверка событий
```bash
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'
```

#### Проверка описания пода
```bash
kubectl describe pod <pod-name> -n mindbox-sre-test
```

#### Проверка логов
```bash
kubectl logs <pod-name> -n mindbox-sre-test
```

### 2. HPA не работает

#### Проверка Metrics Server
```bash
kubectl get deployment metrics-server -n kube-system
kubectl logs deployment/metrics-server -n kube-system
```

#### Проверка HPA статуса
```bash
kubectl describe hpa mindbox-app-hpa -n mindbox-sre-test
```

### 3. Ingress не работает

#### Проверка Ingress Controller
```bash
kubectl get pods -n ingress-nginx
kubectl logs deployment/ingress-nginx-controller -n ingress-nginx
```

#### Проверка Ingress статуса
```bash
kubectl describe ingress mindbox-app-ingress -n mindbox-sre-test
```

## Масштабирование и обновления

### 1. Ручное масштабирование
```bash
# Изменение количества реплик
kubectl scale deployment mindbox-app --replicas=4 -n mindbox-sre-test

# Проверка статуса
kubectl get deployment mindbox-app -n mindbox-sre-test
```

### 2. Обновление приложения
```bash
# Обновление образа
kubectl set image deployment/mindbox-app mindbox-app=new-image:tag -n mindbox-sre-test

# Проверка статуса обновления
kubectl rollout status deployment/mindbox-app -n mindbox-sre-test

# Откат при необходимости
kubectl rollout undo deployment/mindbox-app -n mindbox-sre-test
```

### 3. Обновление конфигурации
```bash
# Обновление ConfigMap
kubectl apply -f k8s/configmap.yaml

# Перезапуск подов для применения изменений
kubectl rollout restart deployment/mindbox-app -n mindbox-sre-test
```

## Удаление

### Полное удаление
```bash
# Удаление всех ресурсов
kubectl delete namespace mindbox-sre-test

# Проверка удаления
kubectl get namespace mindbox-sre-test
```

### Частичное удаление
```bash
# Удаление конкретных ресурсов
kubectl delete deployment mindbox-app -n mindbox-sre-test
kubectl delete service mindbox-app-service -n mindbox-sre-test
kubectl delete ingress mindbox-app-ingress -n mindbox-sre-test
```

## Безопасность

### 1. Проверка Security Context
```bash
# Проверка security context подов
kubectl get pods -n mindbox-sre-test -o yaml | grep -A 10 securityContext
```

### 2. Проверка Network Policy
```bash
# Статус Network Policy
kubectl get networkpolicy -n mindbox-sre-test

# Детали Network Policy
kubectl describe networkpolicy mindbox-app-network-policy -n mindbox-sre-test
```

### 3. Проверка RBAC
```bash
# Проверка Service Account
kubectl get serviceaccount mindbox-app-sa -n mindbox-sre-test -o yaml

# Проверка ролей и привязок
kubectl get rolebinding -n mindbox-sre-test
```

## Производительность

### 1. Нагрузочное тестирование
```bash
# Простой нагрузочный тест
for i in {1..100}; do
  curl -s http://localhost:8080/load-test > /dev/null &
done
wait

# Проверка метрик
curl http://localhost:8080/metrics | grep request_count
```

### 2. Мониторинг производительности
```bash
# Мониторинг в реальном времени
watch -n 1 'kubectl top pods -n mindbox-sre-test'

# Проверка HPA активности
kubectl get hpa -n mindbox-sre-test -w
```

## Заключение

Данное руководство покрывает все аспекты развертывания и обслуживания Mindbox SRE тестового приложения. Следуя этим инструкциям, вы сможете:

1. **Быстро развернуть** приложение в Kubernetes
2. **Настроить мониторинг** и автоматическое масштабирование
3. **Обеспечить отказоустойчивость** и безопасность
4. **Оптимизировать ресурсы** для дневного цикла нагрузки
5. **Устранять неполадки** и поддерживать приложение

При возникновении вопросов или проблем, обращайтесь к документации Kubernetes или команде SRE. 
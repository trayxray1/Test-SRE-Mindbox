# Примеры команд для Mindbox SRE тестового приложения

## Быстрый старт

### 1. Развертывание
```bash
# Автоматическое развертывание
./deploy.sh

# Или ручное развертывание
kubectl apply -f k8s/
```

### 2. Тестирование
```bash
# Автоматическое тестирование
./test.sh

# Или ручное тестирование
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test
curl http://localhost:8080/
```

## Мониторинг и диагностика

### Проверка статуса приложения
```bash
# Общий статус
kubectl get all -n mindbox-sre-test

# Статус подов с деталями
kubectl get pods -n mindbox-sre-test -o wide

# События namespace
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# Логи приложения
kubectl logs -f deployment/mindbox-app -n mindbox-sre-test
```

### Мониторинг ресурсов
```bash
# Использование ресурсов подов
kubectl top pods -n mindbox-sre-test

# Использование ресурсов нод
kubectl top nodes

# Детали ресурсов
kubectl describe resourcequota -n mindbox-sre-test
kubectl describe limitrange -n mindbox-sre-test
```

### Проверка HPA
```bash
# Статус HPA
kubectl get hpa -n mindbox-sre-test

# Детальная информация HPA
kubectl describe hpa mindbox-app-hpa -n mindbox-sre-test

# Мониторинг HPA в реальном времени
kubectl get hpa -n mindbox-sre-test -w
```

## Тестирование функциональности

### Проверка эндпоинтов
```bash
# Запуск port-forward
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test &

# Тест основных эндпоинтов
curl -s http://localhost:8080/ | head -20
curl -s http://localhost:8080/health | jq .
curl -s http://localhost:8080/ready | jq .
curl -s http://localhost:8080/live | jq .
curl -s http://localhost:8080/metrics | head -20
curl -s http://localhost:8080/load-test | jq .

# Остановка port-forward
kill %1
```

### Нагрузочное тестирование
```bash
# Простой нагрузочный тест
echo "Нагрузочный тест: 100 запросов"
time (
  for i in {1..100}; do
    curl -s http://localhost:8080/load-test > /dev/null &
  done
  wait
)
echo "Тест завершен"

# Проверка метрик после нагрузки
curl -s http://localhost:8080/metrics | grep request_count
```

## Управление приложением

### Масштабирование
```bash
# Ручное масштабирование
kubectl scale deployment mindbox-app --replicas=4 -n mindbox-sre-test

# Проверка масштабирования
kubectl get deployment mindbox-app -n mindbox-sre-test
kubectl get pods -n mindbox-sre-test

# Возврат к автоматическому масштабированию
kubectl scale deployment mindbox-app --replicas=2 -n mindbox-sre-test
```

### Обновления
```bash
# Проверка статуса обновления
kubectl rollout status deployment/mindbox-app -n mindbox-sre-test

# История обновлений
kubectl rollout history deployment/mindbox-app -n mindbox-sre-test

# Откат к предыдущей версии
kubectl rollout undo deployment/mindbox-app -n mindbox-sre-test

# Откат к конкретной версии
kubectl rollout undo deployment/mindbox-app --to-revision=1 -n mindbox-sre-test
```

### Конфигурация
```bash
# Обновление ConfigMap
kubectl apply -f k8s/configmap.yaml

# Перезапуск для применения изменений
kubectl rollout restart deployment/mindbox-app -n mindbox-sre-test

# Проверка переменных окружения
kubectl get pods -n mindbox-sre-test -o jsonpath='{.items[0].spec.containers[0].env}'
```

## Диагностика проблем

### Поды не запускаются
```bash
# Проверка событий
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp' | head -20

# Проверка описания пода
kubectl describe pod $(kubectl get pods -n mindbox-sre-test -o jsonpath='{.items[0].metadata.name}') -n mindbox-sre-test

# Проверка логов
kubectl logs $(kubectl get pods -n mindbox-sre-test -o jsonpath='{.items[0].metadata.name}') -n mindbox-sre-test
```

### Проблемы с сетью
```bash
# Проверка Network Policy
kubectl get networkpolicy -n mindbox-sre-test
kubectl describe networkpolicy mindbox-app-network-policy -n mindbox-sre-test

# Проверка Service
kubectl get svc -n mindbox-sre-test
kubectl describe svc mindbox-app-service -n mindbox-sre-test

# Тест DNS
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup mindbox-app-service.mindbox-sre-test.svc.cluster.local
```

### Проблемы с ресурсами
```bash
# Проверка Resource Quota
kubectl describe resourcequota -n mindbox-sre-test

# Проверка Limit Range
kubectl describe limitrange -n mindbox-sre-test

# Проверка доступности ресурсов на нодах
kubectl describe nodes | grep -A 10 "Allocated resources"
```

## Мониторинг производительности

### Метрики в реальном времени
```bash
# Мониторинг подов
watch -n 1 'kubectl get pods -n mindbox-sre-test'

# Мониторинг ресурсов
watch -n 1 'kubectl top pods -n mindbox-sre-test'

# Мониторинг HPA
watch -n 1 'kubectl get hpa -n mindbox-sre-test'
```

### Анализ метрик
```bash
# Получение метрик приложения
curl -s http://localhost:8080/metrics | grep -E "(cpu|memory|request)"

# Анализ логов
kubectl logs deployment/mindbox-app -n mindbox-sre-test | grep -E "(ERROR|WARN|INFO)"

# Проверка событий кластера
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | grep mindbox
```

## Безопасность

### Проверка Security Context
```bash
# Проверка security context подов
kubectl get pods -n mindbox-sre-test -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.securityContext.runAsUser}{"\n"}{end}'

# Проверка capabilities
kubectl get pods -n mindbox-sre-test -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].securityContext.capabilities.drop}{"\n"}{end}'
```

### Проверка RBAC
```bash
# Проверка Service Account
kubectl get serviceaccount mindbox-app-sa -n mindbox-sre-test -o yaml

# Проверка ролей
kubectl get roles -n mindbox-sre-test
kubectl get rolebindings -n mindbox-sre-test
```

## Очистка и удаление

### Удаление приложения
```bash
# Удаление всех ресурсов
kubectl delete namespace mindbox-sre-test

# Проверка удаления
kubectl get namespace mindbox-sre-test

# Очистка локальных файлов
rm -rf k8s/ app/ *.sh *.md Dockerfile requirements.txt
```

### Частичная очистка
```bash
# Удаление конкретных ресурсов
kubectl delete deployment mindbox-app -n mindbox-sre-test
kubectl delete service mindbox-app-service -n mindbox-sre-test
kubectl delete ingress mindbox-app-ingress -n mindbox-sre-test
kubectl delete hpa mindbox-app-hpa -n mindbox-sre-test
```

## Полезные команды для отладки

### Общая диагностика
```bash
# Проверка версии кластера
kubectl version --short

# Проверка компонентов кластера
kubectl get componentstatuses

# Проверка namespaces
kubectl get namespaces

# Проверка нод
kubectl get nodes -o wide
```

### Проверка конфигурации
```bash
# Экспорт конфигурации
kubectl get deployment mindbox-app -n mindbox-sre-test -o yaml > deployment-export.yaml

# Проверка аннотаций
kubectl get deployment mindbox-app -n mindbox-sre-test -o jsonpath='{.metadata.annotations}'

# Проверка labels
kubectl get deployment mindbox-app -n mindbox-sre-test -o jsonpath='{.metadata.labels}'
```

### Мониторинг событий
```bash
# События в реальном времени
kubectl get events -n mindbox-sre-test -w

# Фильтрация событий по типу
kubectl get events -n mindbox-sre-test --field-selector type=Warning

# События по времени
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp' | tail -20
```

## Примеры для автоматизации

### Скрипт мониторинга
```bash
#!/bin/bash
# monitor.sh - Скрипт мониторинга приложения

NAMESPACE="mindbox-sre-test"
DEPLOYMENT="mindbox-app"

echo "=== Мониторинг $DEPLOYMENT в namespace $NAMESPACE ==="
echo "Время: $(date)"
echo ""

echo "Статус подов:"
kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT

echo ""
echo "Использование ресурсов:"
kubectl top pods -n $NAMESPACE -l app=$DEPLOYMENT

echo ""
echo "Статус HPA:"
kubectl get hpa -n $NAMESPACE

echo ""
echo "Последние события:"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -5
```

### Скрипт нагрузочного тестирования
```bash
#!/bin/bash
# load-test.sh - Скрипт нагрузочного тестирования

URL="http://localhost:8080"
REQUESTS=100
CONCURRENT=10

echo "Нагрузочный тест: $REQUESTS запросов, $CONCURRENT параллельно"
echo "URL: $URL"
echo "Время: $(date)"
echo ""

# Запуск port-forward
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test &
PF_PID=$!
sleep 5

# Нагрузочный тест
echo "Запуск теста..."
time (
  for i in $(seq 1 $REQUESTS); do
    if (( i % $CONCURRENT == 0 )); then
      wait
    fi
    curl -s "$URL/load-test" > /dev/null &
  done
  wait
)

echo ""
echo "Тест завершен"
echo "Проверка метрик..."

# Проверка метрик
curl -s "$URL/metrics" | grep request_count || echo "Метрики недоступны"

# Остановка port-forward
kill $PF_PID 2>/dev/null || true
```

## Заключение

Эти примеры команд помогут вам:

1. **Быстро развернуть** и протестировать приложение
2. **Мониторить** производительность и ресурсы
3. **Диагностировать** проблемы и неполадки
4. **Автоматизировать** рутинные операции
5. **Обеспечить** стабильную работу приложения

Используйте эти команды как основу для создания собственных скриптов и автоматизации. 
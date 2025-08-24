# Архитектурные решения для Mindbox SRE тестового задания

## Обзор требований

- **Мультизональный кластер**: 3 зоны, 5 нод
- **Время инициализации**: 5-10 секунд
- **Нагрузка**: 4 пода справляются с пиковой нагрузкой
- **Ресурсы**: CPU 0.1 (после инициализации), Memory 128M
- **Дневной цикл нагрузки**: ночью меньше, пик днем
- **Цели**: максимальная отказоустойчивость, минимальное потребление ресурсов

## Принятые архитектурные решения

### 1. Стратегия развертывания

#### Rolling Update Strategy
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Максимум 1 дополнительный под
    maxUnavailable: 0  # Не допускать недоступности
```

**Обоснование**: Обеспечивает zero-downtime обновления, что критично для production среды.

#### Реплики и масштабирование
- **Минимум**: 2 пода для отказоустойчивости
- **Максимум**: 8 подов для пиковой нагрузки
- **HPA**: Автоматическое масштабирование по CPU и Memory

### 2. Распределение по зонам

#### Pod Anti-Affinity
```yaml
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      topologyKey: topology.kubernetes.io/zone
```

**Обоснование**: Распределение подов по разным зонам обеспечивает максимальную отказоустойчивость при сбое одной зоны.

#### Node Affinity
```yaml
nodeAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 80
    preference:
      matchExpressions:
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ["e2-medium", "e2-standard-2", "n1-standard-2"]
```

**Обоснование**: Предпочтение нод с достаточными ресурсами для оптимального размещения.

### 3. Управление ресурсами

#### Resource Requests/Limits
```yaml
resources:
  requests:
    cpu: "50m"        # 0.05 CPU для базовой работы
    memory: "64Mi"    # 64 Mi для базовой работы
  limits:
    cpu: "500m"       # 0.5 CPU для пиковой нагрузки
    memory: "256Mi"   # 256 Mi с запасом
```

**Обоснование**: 
- **Requests**: Минимальные гарантированные ресурсы для стабильной работы
- **Limits**: Защита от исчерпания ресурсов ноды
- **Оптимизация**: Учет дневного цикла нагрузки

#### Resource Quota
```yaml
hard:
  requests.cpu: "4"      # Максимум 4 CPU
  limits.cpu: "8"        # Максимум 8 CPU
  requests.memory: "2Gi" # Максимум 2 Gi
  limits.memory: "4Gi"   # Максимум 4 Gi
```

**Обоснование**: Контроль общего потребления ресурсов в namespace, предотвращение исчерпания ресурсов кластера.

### 4. Проверки здоровья

#### Startup Probe
```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 5000
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 20      # 100 секунд максимум
```

**Обоснование**: Учитывает время инициализации 5-10 секунд, предотвращает преждевременные проверки readiness.

#### Readiness Probe
```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 5000
  periodSeconds: 10
  failureThreshold: 3
```

**Обоснование**: Проверка готовности принимать трафик, интеграция с Service для правильной маршрутизации.

#### Liveness Probe
```yaml
livenessProbe:
  httpGet:
    path: /live
    port: 5000
  periodSeconds: 30
  failureThreshold: 3
```

**Обоснование**: Проверка работоспособности, перезапуск контейнера при сбое.

### 5. Автоматическое масштабирование

#### HPA конфигурация
```yaml
minReplicas: 2
maxReplicas: 8
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 70
```

**Обоснование**: 
- **CPU 70%**: Оптимальный порог для масштабирования
- **Memory 80%**: Предотвращение OOM
- **Поведение**: Быстрое масштабирование вверх, медленное вниз

#### HPA Behavior
```yaml
scaleUp:
  stabilizationWindowSeconds: 60    # 1 минута
scaleDown:
  stabilizationWindowSeconds: 300   # 5 минут
```

**Обоснование**: Учет дневного цикла нагрузки, предотвращение частого масштабирования.

### 6. Безопасность

#### Security Context
```yaml
securityContext:
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop: ["ALL"]
```

**Обоснование**: Принцип наименьших привилегий, защита от privilege escalation.

#### Network Policy
```yaml
ingress:
- ports:
  - protocol: TCP
    port: 5000
  from:
  - namespaceSelector:
      matchLabels:
        name: mindbox-sre-test
```

**Обоснование**: Контроль сетевого трафика, изоляция приложения.

### 7. Мониторинг и логирование

#### Prometheus аннотации
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "5000"
  prometheus.io/path: "/metrics"
```

**Обоснование**: Автоматическое обнаружение метрик, интеграция с мониторингом.

#### Метрики приложения
- **CPU Usage**: Мониторинг производительности
- **Memory Usage**: Контроль потребления памяти
- **Request Count**: Анализ нагрузки
- **Custom Metrics**: Бизнес-метрики

### 8. Отказоустойчивость

#### Pod Disruption Budget
```yaml
minAvailable: 2  # Всегда доступно минимум 2 пода
```

**Обоснование**: Защита от случайного удаления подов, обеспечение доступности.

#### Толеранции
```yaml
tolerations:
- key: "node-role.kubernetes.io/control-plane"
  operator: "Exists"
  effect: "NoSchedule"
```

**Обоснование**: Возможность размещения на control-plane нодах при необходимости.

## Оптимизация для дневного цикла нагрузки

### 1. HPA настройки
- **Быстрое масштабирование вверх**: 1 минута стабилизации
- **Медленное масштабирование вниз**: 5 минут стабилизации
- **Минимум 2 пода**: Обеспечение базовой доступности ночью

### 2. Ресурсы
- **Requests**: Минимальные для ночной нагрузки
- **Limits**: Достаточные для дневного пика
- **Буфер**: 20% запас для непредвиденных нагрузок

### 3. Мониторинг
- **Алерты**: Предупреждения при высокой нагрузке
- **Метрики**: Отслеживание трендов нагрузки
- **Автоматизация**: HPA для адаптации к нагрузке

## Метрики эффективности

### 1. Отказоустойчивость
- **SLA**: 99.9% доступности
- **RTO**: < 5 минут восстановления
- **RPO**: 0 потери данных

### 2. Эффективность ресурсов
- **CPU Utilization**: 70% в пике, 10% в спокойное время
- **Memory Utilization**: 80% в пике, 50% в спокойное время
- **Cost Optimization**: Автоматическое масштабирование

### 3. Производительность
- **Response Time**: < 100ms для 95% запросов
- **Throughput**: Масштабирование до 8 подов
- **Latency**: Оптимизация для мультизональности

## Заключение

Предложенная архитектура обеспечивает:
1. **Максимальную отказоустойчивость** через распределение по зонам
2. **Минимальное потребление ресурсов** через HPA и оптимизацию
3. **Адаптивность к нагрузке** через автоматическое масштабирование
4. **Безопасность** через security context и network policies
5. **Мониторинг** через интеграцию с Prometheus и Grafana

Архитектура готова к production использованию и может быть легко адаптирована под конкретные требования. 
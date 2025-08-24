#!/usr/bin/env python3
"""
Mindbox SRE Test Application
Веб-приложение для демонстрации Kubernetes развертывания
"""

import os
import time
import psutil
import threading
from datetime import datetime
from flask import Flask, jsonify, request, render_template_string

app = Flask(__name__)

# Глобальные переменные для отслеживания состояния
start_time = time.time()
request_count = 0
is_ready = False

# HTML шаблон для главной страницы
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mindbox SRE Test App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .status { padding: 15px; margin: 10px 0; border-radius: 5px; }
        .ready { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .not-ready { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .metric { display: inline-block; margin: 10px; padding: 10px; background: #e9ecef; border-radius: 5px; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 5px; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Mindbox SRE Test Application</h1>
        
        <div class="status {{ 'ready' if is_ready else 'not-ready' }}">
            <strong>Статус:</strong> {{ 'Готов к работе' if is_ready else 'Инициализация...' }}
        </div>
        
        <div class="info">
            <h3>📊 Метрики приложения</h3>
            <div class="metric">
                <strong>Время работы:</strong> {{ uptime }}
            </div>
            <div class="metric">
                <strong>Запросов:</strong> {{ request_count }}
            </div>
            <div class="metric">
                <strong>Pod:</strong> {{ pod_name }}
            </div>
            <div class="metric">
                <strong>Зона:</strong> {{ zone }}
            </div>
        </div>
        
        <div class="info">
            <h3>🔧 Тестовые эндпоинты</h3>
            <button onclick="testHealth()">Проверить здоровье</button>
            <button onclick="testMetrics()">Получить метрики</button>
            <button onclick="testLoad()">Тест нагрузки</button>
        </div>
        
        <div id="results"></div>
    </div>
    
    <script>
        async function testHealth() {
            const response = await fetch('/health');
            const data = await response.json();
            document.getElementById('results').innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        }
        
        async function testMetrics() {
            const response = await fetch('/metrics');
            const data = await response.json();
            document.getElementById('results').innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        }
        
        async function testLoad() {
            const response = await fetch('/load-test');
            const data = await response.json();
            document.getElementById('results').innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
        }
    </script>
</body>
</html>
"""

def simulate_initialization():
    """Имитация инициализации приложения (5-10 секунд)"""
    global is_ready
    time.sleep(8)  # 8 секунд для имитации инициализации
    is_ready = True
    app.logger.info("Приложение готово к работе")

@app.route('/')
def index():
    """Главная страница приложения"""
    global request_count
    request_count += 1
    
    uptime = time.strftime('%H:%M:%S', time.gmtime(time.time() - start_time))
    pod_name = os.environ.get('POD_NAME', 'unknown')
    zone = os.environ.get('ZONE', 'unknown')
    
    return render_template_string(HTML_TEMPLATE, 
                                is_ready=is_ready,
                                uptime=uptime,
                                request_count=request_count,
                                pod_name=pod_name,
                                zone=zone)

@app.route('/health')
def health():
    """Эндпоинт для проверки здоровья приложения"""
    global is_ready
    
    if is_ready:
        return jsonify({
            'status': 'healthy',
            'ready': True,
            'timestamp': datetime.now().isoformat(),
            'uptime': time.time() - start_time
        }), 200
    else:
        return jsonify({
            'status': 'initializing',
            'ready': False,
            'timestamp': datetime.now().isoformat(),
            'uptime': time.time() - start_time
        }), 503

@app.route('/ready')
def ready():
    """Эндпоинт для readiness probe"""
    global is_ready
    if is_ready:
        return jsonify({'status': 'ready'}), 200
    else:
        return jsonify({'status': 'not ready'}), 503

@app.route('/live')
def live():
    """Эндпоинт для liveness probe"""
    return jsonify({'status': 'alive'}), 200

@app.route('/metrics')
def metrics():
    """Эндпоинт для получения метрик приложения"""
    process = psutil.Process()
    memory_info = process.memory_info()
    
    return jsonify({
        'pod_name': os.environ.get('POD_NAME', 'unknown'),
        'zone': os.environ.get('ZONE', 'unknown'),
        'node': os.environ.get('NODE_NAME', 'unknown'),
        'cpu_percent': process.cpu_percent(),
        'memory_mb': memory_info.rss / 1024 / 1024,
        'memory_percent': process.memory_percent(),
        'request_count': request_count,
        'uptime_seconds': time.time() - start_time,
        'is_ready': is_ready,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/load-test')
def load_test():
    """Эндпоинт для тестирования нагрузки"""
    # Имитация нагрузки - вычисление простых математических операций
    result = 0
    for i in range(1000000):
        result += i * 0.1
    
    return jsonify({
        'status': 'load test completed',
        'result': result,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/startup')
def startup():
    """Эндпоинт для startup probe"""
    global is_ready
    if is_ready:
        return jsonify({'status': 'started'}), 200
    else:
        return jsonify({'status': 'starting'}), 503

if __name__ == '__main__':
    # Запуск инициализации в отдельном потоке
    init_thread = threading.Thread(target=simulate_initialization)
    init_thread.daemon = True
    init_thread.start()
    
    # Запуск Flask приложения
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False) 
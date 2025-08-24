# 🌍 Руководства по платформам - Mindbox SRE тестовое задание

## 🎯 Обзор

Этот файл содержит инструкции по запуску проекта на различных платформах и в разных средах. Выберите подходящий раздел для вашей платформы.

## 🪟 Windows

### **Предварительные требования**
- Windows 10/11
- PowerShell 5.1+ или PowerShell Core
- kubectl для Windows
- Kubernetes кластер (Minikube, Docker Desktop, Kind, или удаленный)

### **Установка инструментов**

#### Через Chocolatey (рекомендуется)
```powershell
# Установка Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Установка kubectl
choco install kubernetes-cli

# Установка curl (опционально)
choco install curl
```

#### Ручная установка
```powershell
# Скачать kubectl.exe с официального сайта
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### **Настройка кластера**

#### Docker Desktop Kubernetes
```powershell
# 1. Установить Docker Desktop
# 2. Включить Kubernetes в настройках
# 3. Проверить статус
kubectl cluster-info
```

#### Minikube
```powershell
# Установка Minikube
choco install minikube

# Запуск кластера
minikube start --driver=hyperv

# Проверка статуса
minikube status
```

#### Kind
```powershell
# Установка Kind
choco install kind

# Создание кластера
kind create cluster --name mindbox-test

# Проверка статуса
kind get clusters
```

### **Запуск проекта**
```powershell
# 1. Развертывание
.\deploy.ps1

# 2. Тестирование
.\test.ps1

# 3. Доступ к приложению
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test
# Откройте http://localhost:8080 в браузере
```

### **Полезные команды PowerShell**
```powershell
# Проверка версии Windows
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion

# Проверка версии PowerShell
$PSVersionTable.PSVersion

# Проверка доступных команд
Get-Command kubectl*
```

## 🐧 Linux

### **Предварительные требования**
- Ubuntu 18.04+, CentOS 7+, или другой дистрибутив
- bash shell
- kubectl
- Kubernetes кластер

### **Установка инструментов**

#### Ubuntu/Debian
```bash
# Обновление пакетов
sudo apt update && sudo apt upgrade -y

# Установка kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Установка curl (если не установлен)
sudo apt install curl -y
```

#### CentOS/RHEL
```bash
# Установка kubectl
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y kubectl
```

### **Настройка кластера**

#### Minikube
```bash
# Установка Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Запуск кластера
minikube start

# Проверка статуса
minikube status
```

#### Kind
```bash
# Установка Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Создание кластера
kind create cluster --name mindbox-test

# Проверка статуса
kind get clusters
```

#### MicroK8s (Ubuntu)
```bash
# Установка MicroK8s
sudo snap install microk8s --classic

# Добавление пользователя в группу
sudo usermod -a -G microk8s $USER
newgrp microk8s

# Включение необходимых компонентов
microk8s enable dns ingress storage

# Настройка kubectl
microk8s kubectl config view --raw > ~/.kube/config
```

### **Запуск проекта**
```bash
# 1. Сделать скрипты исполняемыми
chmod +x deploy.sh test.sh

# 2. Развертывание
./deploy.sh

# 3. Тестирование
./test.sh

# 4. Доступ к приложению
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test
# Откройте http://localhost:8080 в браузере
```

### **Полезные команды Linux**
```bash
# Проверка версии ОС
cat /etc/os-release

# Проверка версии bash
bash --version

# Проверка доступных команд
which kubectl
kubectl version --client
```

## 🍎 macOS

### **Предварительные требования**
- macOS 10.15+ (Catalina)
- bash или zsh shell
- kubectl
- Kubernetes кластер

### **Установка инструментов**

#### Через Homebrew (рекомендуется)
```bash
# Установка Homebrew (если не установлен)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Установка kubectl
brew install kubectl

# Установка curl (если не установлен)
brew install curl
```

#### Ручная установка
```bash
# Скачать kubectl для macOS
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### **Настройка кластера**

#### Docker Desktop Kubernetes
```bash
# 1. Установить Docker Desktop для Mac
# 2. Включить Kubernetes в настройках
# 3. Проверить статус
kubectl cluster-info
```

#### Minikube
```bash
# Установка Minikube
brew install minikube

# Запуск кластера
minikube start

# Проверка статуса
minikube status
```

#### Kind
```bash
# Установка Kind
brew install kind

# Создание кластера
kind create cluster --name mindbox-test

# Проверка статуса
kind get clusters
```

### **Запуск проекта**
```bash
# 1. Сделать скрипты исполняемыми
chmod +x deploy.sh test.sh

# 2. Развертывание
./deploy.sh

# 3. Тестирование
./test.sh

# 4. Доступ к приложению
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test
# Откройте http://localhost:8080 в браузере
```

### **Полезные команды macOS**
```bash
# Проверка версии macOS
sw_vers

# Проверка версии bash
bash --version

# Проверка доступных команд
which kubectl
kubectl version --client
```

## ☁️ Облачные платформы

### **Google Cloud Platform (GKE)**

#### Установка gcloud CLI
```bash
# Linux
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# macOS
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Windows
# Скачать установщик с https://cloud.google.com/sdk/docs/install
```

#### Создание кластера
```bash
# Аутентификация
gcloud auth login

# Установка проекта
gcloud config set project YOUR_PROJECT_ID

# Создание кластера
gcloud container clusters create mindbox-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type e2-standard-2

# Получение учетных данных
gcloud container clusters get-credentials mindbox-cluster --zone us-central1-a
```

### **Amazon Web Services (EKS)**

#### Установка AWS CLI
```bash
# Linux/macOS
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Скачать установщик с https://aws.amazon.com/cli/
```

#### Создание кластера
```bash
# Настройка AWS CLI
aws configure

# Создание кластера EKS
eksctl create cluster \
  --name mindbox-cluster \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 5
```

### **Microsoft Azure (AKS)**

#### Установка Azure CLI
```bash
# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# macOS
brew install azure-cli

# Windows
# Скачать установщик с https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
```

#### Создание кластера
```bash
# Аутентификация
az login

# Создание группы ресурсов
az group create --name mindbox-rg --location eastus

# Создание кластера AKS
az aks create \
  --resource-group mindbox-rg \
  --name mindbox-cluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Получение учетных данных
az aks get-credentials --resource-group mindbox-rg --name mindbox-cluster
```

## 🐳 Docker

### **Docker Desktop**

#### Windows/macOS
```bash
# 1. Установить Docker Desktop
# 2. Включить Kubernetes в настройках
# 3. Проверить статус
kubectl cluster-info
```

#### Linux
```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### **Запуск с Docker**
```bash
# Сборка образа
docker build -t mindbox-app:latest .

# Запуск контейнера
docker run -d -p 8080:5000 --name mindbox-app mindbox-app:latest

# Проверка статуса
docker ps

# Логи
docker logs mindbox-app

# Остановка
docker stop mindbox-app
docker rm mindbox-app
```

## 🔧 Общие команды для всех платформ

### **Проверка окружения**
```bash
# Проверка версии kubectl
kubectl version --client

# Проверка подключения к кластеру
kubectl cluster-info

# Проверка нод
kubectl get nodes

# Проверка namespaces
kubectl get namespaces
```

### **Развертывание проекта**
```bash
# Создание всех ресурсов
kubectl apply -f k8s/

# Ожидание готовности
kubectl wait --for=condition=ready pod -l app=mindbox-app -n mindbox-sre-test --timeout=300s

# Проверка статуса
kubectl get all -n mindbox-sre-test
```

### **Доступ к приложению**
```bash
# Port-forward
kubectl port-forward svc/mindbox-app-service 8080:80 -n mindbox-sre-test

# В другом терминале - тестирование
curl http://localhost:8080/
curl http://localhost:8080/health
```

### **Мониторинг**
```bash
# Статус подов
kubectl get pods -n mindbox-sre-test

# HPA статус
kubectl get hpa -n mindbox-sre-test

# Ресурсы
kubectl top pods -n mindbox-sre-test

# Логи
kubectl logs -f deployment/mindbox-app -n mindbox-sre-test
```

### **Очистка**
```bash
# Удаление всех ресурсов
kubectl delete namespace mindbox-sre-test

# Проверка удаления
kubectl get namespace mindbox-sre-test
```

## 🚨 Устранение неполадок

### **Общие проблемы**

#### kubectl не найден
```bash
# Проверить PATH
echo $PATH

# Проверить установку
which kubectl

# Переустановить kubectl
```

#### Не удается подключиться к кластеру
```bash
# Проверить контекст
kubectl config current-context

# Проверить конфигурацию
kubectl config view

# Переключить контекст
kubectl config use-context <context-name>
```

#### Поды не запускаются
```bash
# Проверить события
kubectl get events -n mindbox-sre-test --sort-by='.lastTimestamp'

# Проверить описание пода
kubectl describe pod <pod-name> -n mindbox-sre-test

# Проверить логи
kubectl logs <pod-name> -n mindbox-sre-test
```

### **Платформо-специфичные проблемы**

#### Windows
- **PowerShell Execution Policy**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Проблемы с портами**: Проверить `netstat -an | findstr :8080`
- **Docker Desktop**: Перезапустить Docker Desktop

#### Linux
- **Права доступа**: `chmod +x deploy.sh test.sh`
- **SELinux**: Проверить настройки SELinux
- **Firewall**: Проверить настройки firewall

#### macOS
- **Docker Desktop**: Перезапустить Docker Desktop
- **Права доступа**: `chmod +x deploy.sh test.sh`
- **Homebrew**: Обновить Homebrew

## 🎉 Заключение

Данные руководства покрывают:

1. **Установку инструментов** на всех основных платформах
2. **Настройку кластеров** для локальной разработки
3. **Интеграцию с облачными платформами** (GKE, EKS, AKS)
4. **Запуск проекта** на любой платформе
5. **Устранение неполадок** для каждой платформы

### **Рекомендации по платформам**

- **Windows**: Docker Desktop Kubernetes или Minikube
- **Linux**: Minikube, Kind, или MicroK8s
- **macOS**: Docker Desktop Kubernetes или Minikube
- **Production**: GKE, EKS, или AKS

Проект полностью совместим со всеми платформами и готов к использованию!

---

**Автор**: SRE Engineer  
**Дата**: $(date)  
**Версия**: 1.0.0  
**Платформы**: Windows, Linux, macOS, Cloud  
**Статус**: ✅ Готово к использованию на всех платформах 
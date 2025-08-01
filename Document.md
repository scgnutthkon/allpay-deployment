# AllPay System Infrastructure Overview

This document describes the infrastructure components of the **AllPay System**, which is hosted on a local Kubernetes cluster using `kubeadm`, under the namespace `allpay`.

---

## 📑 Table of Contents

1. [Kubernetes Cluster](#kubernetes-cluster)
2. [Helm Deployments](#helm-deployments)
3. [Kubernetes Services](#kubernetes-services)
4. [Persistent Storage (NFS)](#persistent-storage-nfs)
5. [NFS Server Configuration](#nfs-server-configuration)
6. [NGINX Reverse Proxy](#nginx-reverse-proxy)
7. [Troubleshooting](#troubleshooting)
   - [Cannot Access Service via Domain or IP](#cannot-access-domain)
   - [502 Bad Gateway or 504 Gateway Timeout](#bad-gateway)
   - [Web Service Not Running](#web-service-not-running)
   - [Application Error Occurred](#application-error-occurred)
   - [Cannot connect to database (PostgreSQL)](#cannot-connect-database-postgresql)
   - [Cannot connect to database (MongoDB)](#cannot-connect-database-mongodb)
8. [System Health Checks](#system-health-checks)
   - [Check Disk Usage](#check-disk-usage)
   - [Check Running Services](#check-running-services)
   - [Check Application Services](#check-application-services)
   - [Check Network Connectivity](#check-network-connectivity)
9. [Security Scan Issues](#security-scan-issues)
   - [Fix issue SSL Medium Strength Cipher Suites Supported](#issue-ssl-medium-strength)

---

## 🧩 Kubernetes Cluster <a id="kubernetes-cluster"></a>

- **Type**: Local Kubernetes Cluster (`kubeadm`)
- **Namespace**: `allpay`
- **Helm Usage**: All components are deployed via Helm charts.

---

## 🚀 Helm Deployments <a id="helm-deployments"></a>

| Name                     | Chart Version                      |
|--------------------------|------------------------------------|
| allpay-background-service | allpay-background-service-v1.2.2   |
| allpay-dbmigration        | allpay-dbmigration-v2.1.3          |
| allpay-mq-service         | allpay-mq-service-v0.2.108         |
| allpay-rabbitmq           | rabbitmq-14.6.5                    |
| allpay-redis              | redis-19.6.4                       |
| allpay-web                | allpay-web-v1.3.2                  |
| allpay-webapi             | allpay-webapi-v1.3.3               |
| jsreport                  | jsreport-0.1.0                     |
| vendor-portal-web         | vendor-portal-web-v1.2.0           |
| vendor-portal-webapi      | vendor-portal-webapi-v1.1.0        |

---

## 🌐 Services <a id="kubernetes-services"></a>

| Name                    | Type       | Cluster IP      | Port(s)                                        |
|-------------------------|------------|------------------|------------------------------------------------|
| allpay-background-service | ClusterIP | 10.102.218.62   | 8080/TCP                                       |
| allpay-mq-service         | ClusterIP | 10.101.245.112  | 8080/TCP                                       |
| allpay-rabbitmq          | ClusterIP | 10.103.123.74   | 5672, 4369, 25672, 15672/TCP                   |
| allpay-rabbitmq-headless | ClusterIP | None            | 4369, 5672, 25672, 15672/TCP                   |
| allpay-redis-master      | ClusterIP | 10.98.43.70     | 6379/TCP                                       |
| allpay-redis-headless    | ClusterIP | None            | 6379/TCP                                       |
| allpay-web               | ClusterIP | 10.96.215.76    | 3000/TCP                                       |
| allpay-webapi            | ClusterIP | 10.97.246.34    | 8080/TCP                                       |
| jsreport                 | ClusterIP | 10.96.250.159   | 5488/TCP                                       |
| vendor-portal-web        | ClusterIP | 10.106.99.118   | 3000/TCP                                       |
| vendor-portal-webapi     | ClusterIP | 10.108.52.119   | 8080/TCP                                       |

---

## 📦 Persistent Storage (NFS) <a id="persistent-storage-nfs"></a>

NFS is used as the backend for persistent volumes, allowing shared access and long-term data retention.

### Persistent Volumes (PVs)

| Name              | Capacity | Access Modes | Reclaim Policy | NFS Path                      |
|-------------------|----------|--------------|----------------|-------------------------------|
| allpay-redis      | 10Gi     | RWO          | Retain         | /var/nfs/allpay-redis         |
| allpay-rabbitmq   | 10Gi     | RWO          | Retain         | /var/nfs/allpay-rabbitmq      |
| allpay-storage    | 250Gi    | RWX          | Retain         | /var/nfs/allpay-files         |
| jsreport-data     | 4Gi      | RWO          | Retain         | /var/nfs/jsreport-data        |

### Persistent Volume Claims (PVCs)

| PVC Name                             | Volume Name       | Capacity | Access Mode | StorageClass              |
|--------------------------------------|-------------------|----------|-------------|----------------------------|
| allpay/allpay-storage                | allpay-storage    | 250Gi    | RWX         | allpay-storage             |
| allpay/data-allpay-rabbitmq-0       | allpay-rabbitmq   | 10Gi     | RWO         | allpay-rabbitmq-storage    |
| allpay/redis-data-allpay-redis-master-0 | allpay-redis    | 10Gi     | RWO         | allpay-redis-storage       |
| allpay/jsreport-data                | jsreport-data     | 4Gi      | RWO         | jsreport-data              |

---

## 📡 NFS Export Configuration <a id="nfs-server-configuration"></a>

### 🔧 Configuration File

Located at:  
`/etc/exports`

```bash
/var/nfs/allpay-redis       10.101.3.0/24(rw,async,no_subtree_check)
/var/nfs/allpay-rabbitmq    10.101.3.0/24(rw,async,no_subtree_check)
/var/nfs/allpay-files       10.101.3.0/24(rw,async,no_subtree_check)
/var/nfs/jsreport-data      10.101.3.0/24(rw,async,no_subtree_check)
```

---

## 🌐 NGINX Reverse Proxy <a id="nginx-reverse-proxy"></a>

The AllPay system uses **NGINX** as a reverse proxy in front of the Kubernetes services, with **HTTPS termination** and forwarding to the internal Kubernetes service via an upstream IP.

### 📡 Upstream Definition

Upstream mapping to `nginx ingress` `NodePort` command to get ip address:
```bash
kubectl get svc -n ingress-nginx
```
### 🔧 Configuration File

Located at:  
`/etc/nginx/conf.d/k8s-ingress.conf`

```nginx
upstream k8s_backend {
        server 10.103.216.139; #Inginx ingress ip address
}


server {
    listen 80;
#    server_name example.com www.example.com;

    # Redirect all HTTP requests to HTTPS
    return 301 https://$host$request_uri;
}

map $http_connection $connection_upgrade {
    "~*Upgrade" $http_connection;
    default keep-alive;
}

server {
#       listen 80;
        listen 443 ssl;
        server_name _;

        ssl_certificate /etc/ssl/certs/star_scg_com.crt;
        ssl_certificate_key /etc/ssl/private/star_scg_com.key;

        client_max_body_size 100M;

        location / {
            # Forward requests to Jenkins
            proxy_pass http://k8s_backend;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Connection "";
            proxy_cache off;
            proxy_http_version 1.1; # for supported websocket
            proxy_read_timeout 300s;

            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Port $server_port;

            proxy_buffering                         off;
            proxy_buffer_size                       256k;
            proxy_buffers                           8 256k;

            # Security Headers
            add_header Strict-Transport-Security "max-age=31536000" always;
            add_header X-Frame-Options "SAMEORIGIN";
            add_header X-Content-Type-Options "nosniff";

        }
}
```

## 🛠 Troubleshooting <a id="troubleshooting"></a>

### Cannot Access Service via Domain or IP <a id="cannot-access-domain"></a>

- Contact Network Team or Kritsada Songtis `kritsson@scg.com`

### `502 Bad Gateway` or `504 Gateway Timeout` <a id="bad-gateway"></a>

- Check if the service backend (ClusterIP) is reachable from the NGINX host:
  ```bash
  curl http://10.103.216.139
  ```
- Check application pods is running:
   ```bash
  kubectl get pod -n allpay
  ```
### Web Service Not Running <a id="web-service-not-running"></a>

- Check the NGINX status to ensure it's running:

  ```bash
  sudo systemctl status nginx
  ```
- If it's not active, try starting it:
  ```bash
  sudo systemctl status nginx
  ```
- If it fails to start, check the NGINX logs using the following command:
  ```bash
  sudo journalctl -u nginx
  ```
### Application Error Occurred <a id="application-error-occurred"></a>

- Check for errors in Kibana: [https://allpay-elk.scg.com/](https://allpay-elk.scg.com/)

### Cannot connect to database (PostgreSQL) <a id="cannot-connect-database-postgresql"></a>

- Check database service on `10.101.3.156`

    ```bash
    sudo systemctl status postgresql
    sudo pg_lsclusters # Check postgresql cluster
    ```
- Check firewall (run command on application servers `10.101.3.153-155`)
    ```bash
    telnet 10.101.3.156 5432
    ```
    If firewall is not allow contact Network Team or Kritsada Songtis `kritsson@scg.com`

### Cannot connect to database (MongoDB) <a id="cannot-connect-database-mongodb"></a>

- Check database service on `10.101.3.156`

    ```bash
    sudo systemctl status mongod
    ```
- Check firewall (run command on application servers `10.101.3.153-155`)
    ```bash
    telnet 10.101.3.156 27017
    ```
    If firewall is not allow contact Network Team or Kritsada Songtis `kritsson@scg.com`

## 🧾 System Health Checks <a id="system-health-checks"></a>

#### ✅ Check Disk Usage <a id="check-disk-usage"></a>

```bash
df -h
```

#### 🛠 Check Running Services (e.g., nginx, docker, etc.) <a id="check-running-services"></a>

```bash
sudo systemctl status nginx
sudo systemctl status docker
```

List all failed services:

```bash
systemctl --failed
```
#### 📦 Check Application Services (Pod) <a id="check-application-services"></a>

```bash
kubectl get pod -n allpay
```

#### 🌐 Check Network Connectivity <a id="check-network-connectivity"></a>

Check current IP and interface info:

```bash
ip a
```

Check DNS resolution:

```bash
nslookup allpay-vendor.scg.com
```

## 🔒 Security Scan Issues <a id="security-scan-issues"></a>

### Fix issue SSL Medium Strength Cipher Suites Supported (SWEET32)-Synopsis: <a id="issue-ssl-medium-strength"></a>

1. Edit Kubernetes API server manifest (usually located at `/etc/kubernetes/manifests/kube-apiserver.yaml`).

2. Add or update the `--tls-cipher-suites` flag, specifying only strong ciphers. For example:

    ```yaml
    spec:
    containers:
        - name: kube-apiserver
        command:
            - kube-apiserver
            - --tls-cipher-suites=TLS_AES_256_GCM_SHA384,TLS_AES_128_GCM_SHA256,TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    ```
3. Save the file and restart the Kubernetes:
    ```bash
    sudo systemctl restart kubelet
    ```
    #### Verify Changes:
    After applying the changes, verify that weak ciphers are disabled using OpenSSL:

    ```bash
    openssl s_client -connect <your_host>:6443 -cipher ECDHE-RSA-DES-CBC3-SHA
    ```
    If the connection fails, the weak cipher has been successfully disabled.




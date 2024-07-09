# AllPay Redis
Add Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Pre-Install
Create PV
```sh
kubectl apply -f ./redis/pv-dev.yaml
```
## Install Redis
#### Dev Environment
```sh
helm install allpay-redis bitnami/redis -f ./redis/values.dev.yaml -n allpay-dev
```

## Uninstall Redis
#### Dev Environment
```sh
helm uninstall allpay-redis -n allpay-dev
```





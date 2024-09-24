# AllPay MongoDB
Add Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Pre-Install
Create PV
```sh
kubectl apply -f ./mongodb/pv-dev.yaml
```
## Install MongoDB
#### Dev Environment
```sh
helm install mongodb bitnami/mongodb -f ./mongodb/values.dev.yaml -n allpay-db-dev
```
#### QAS Environment
```sh
helm install mongodb bitnami/mongodb -f ./mongodb/values.qas.yaml -n allpay-db-qas
```
#### Production Environment
```sh
helm install mongodb bitnami/mongodb -f ./mongodb/values.prd.yaml -n allpay-db
```

## Uninstall MongoDB
#### Dev Environment
```sh
helm uninstall mongodb -n allpay-db-dev
```
#### QAS Environment
```sh
helm uninstall mongodb -n allpay-db-qas
```
#### Production Environment
```sh
helm uninstall mongodb -n allpay-db
```
#### Patch CronJob (Backup) TimeZone (Run after install or upgrade)
```sh
kubectl patch cronjob mongodb-mongodump -n allpay-db -p '{"spec": {"timeZone": "Asia/Bangkok"}}'
```

#### Disable CronJob (Backup)
```sh
kubectl patch cronjob mongodb-mongodump -n allpay-db -p '{"spec": {"suspend": true}}'
```

#### Enable CronJob (Backup)
```sh
kubectl patch cronjob mongodb-mongodump -n allpay-db -p '{"spec": {"suspend": false}}'
```


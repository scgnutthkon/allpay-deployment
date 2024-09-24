# AllPay PostgreSQL
Add Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Pre-Install
Create PV
```sh
kubectl apply -f ./postgresql/pv-dev.yaml
```
## Install PostgreSQL
#### Dev Environment
```sh
helm install postgresql bitnami/postgresql -f ./postgresql/values.dev.yaml -n allpay-db-dev
```
#### QAS Environment
```sh
helm install postgresql bitnami/postgresql -f ./postgresql/values.qas.yaml -n allpay-db-qas
```
#### Production Environment
```sh
helm install postgresql bitnami/postgresql -f ./postgresql/values.prd.yaml -n allpay-db
```

## Uninstall PostgreSQL
#### Dev Environment
```sh
helm uninstall postgresql -n allpay-db-dev
```
#### QAS Environment
```sh
helm uninstall postgresql -n allpay-db-qas
```
#### Production Environment
```sh
helm uninstall postgresql -n allpay-db
```

#### Patch CronJob (Backup) TimeZone (Run after install or upgrade)
```sh
kubectl patch cronjob postgresql-primary-pgdumpall -n allpay-db -p '{"spec": {"timeZone": "Asia/Bangkok"}}'
```

#### Disable CronJob (Backup)
```sh
kubectl patch cronjob postgresql-primary-pgdumpall -n allpay-db -p '{"spec": {"suspend": true}}'
```

#### Enable CronJob (Backup)
```sh
kubectl patch cronjob postgresql-primary-pgdumpall -n allpay-db -p '{"spec": {"suspend": false}}'
```



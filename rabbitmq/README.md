# AllPay RabbitMQ
Add Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Pre-Install
Create PV
```sh
kubectl apply -f ./rabbitmq/pv-dev.yaml
```
## Install RabbitMQ
#### Dev Environment
```sh
helm install allpay-rabbitmq bitnami/rabbitmq -f ./rabbitmq/values.dev.yaml -n allpay-dev
```
#### QAS Environment
```sh
helm install allpay-rabbitmq bitnami/rabbitmq -f ./rabbitmq/values.qas.yaml -n allpay-qas
```

## Uninstall RabbitMQ
#### Dev Environment
```sh
helm uninstall allpay-rabbitmq -n allpay-dev
```
#### QAS Environment
```sh
helm uninstall allpay-rabbitmq -n allpay-qas
```

## Post Install
Change password of user by enter the container.
```sh
 kubectl exec -it  allpay-rabbitmq-0 -n allpay-dev -- /bin/bash
```
Run command for change password in container
```sh
rabbitmqctl change_password admin mflv[1234
```



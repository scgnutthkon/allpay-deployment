# AllPay RabbitMQ
Add Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Install RabbitMQ
#### Dev Environment
```sh
helm install allpay-rabbitmq bitnami/rabbitmq -f ./rabbitmq/values.dev.yaml -n allpay-dev
```

## Uninstall RabbitMQ
#### Dev Environment
```sh
helm uninstall allpay-rabbitmq -n allpay-dev
```
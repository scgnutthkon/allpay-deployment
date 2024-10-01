# AllPay JSReport
Add Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Pre-Install
Create PV
```sh
kubectl apply -f ./jsreport/pv-dev.yaml
```
## Install JSReport
#### Dev Environment
```sh
helm install jsreport ./jsreport -f ./jsreport/values.dev.yaml -n allpay-dev
```
#### QAS Environment
```sh
helm install jsreport ./jsreport -f ./jsreport/values.qas.yaml -n allpay-qas
```
#### Production Environment
```sh
helm install jsreport ./jsreport -f ./jsreport/values.prd.yaml -n allpay
```

## Uninstall JSReport
#### Dev Environment
```sh
helm uninstall postgresql -n allpay-dev
```
#### QAS Environment
```sh
helm uninstall postgresql -n allpay-qas
```
#### Production Environment
```sh
helm uninstall postgresql -n allpay
```



##############################################################################
##Config apt proxy

# Proxy Env

#proxyUrl="http://10.100.12.240:6969/"
proxyUrl="http://CADAllpayVendor05:Avd%40%400513579@proxy-server.scg.com:3128/"
proxyEsp=$(echo $proxyUrl | sed s/%/%%/g)

export http_proxy="$proxyUrl"
export https_proxy="$proxyUrl"
export ftp_proxy="$proxyUrl"
export no_proxy=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

# Create Namespace
kubectl create namespace allpay-dev

##########################Install redis#################################
kubectl apply -f ./redis/pv-dev.yaml

helm install allpay-redis bitnami/redis -f ./redis/values.dev.yaml -n allpay-dev

##########################Install RabbitMQ#################################
kubectl apply -f ./rabbitmq/pv-dev.yaml

helm install allpay-rabbitmq bitnami/rabbitmq -f ./rabbitmq/values.dev.yaml -n allpay-dev

##########################Install JS Report#################################
kubectl apply -f ./jsreport/pv-dev.yaml

helm install jsreport ./jsreport -f ./jsreport/values.dev.yaml -n allpay-dev

##########################Create App Namespace PV & PVC#################################
# Create PV
kubectl apply -f ./allpay-pv/allpay-dev-pv.yaml
# Create PVC
kubectl apply -f ./allpay-pv/allpay-dev-pvc.yaml -n allpay-dev

##########################Install Allpay Apps#################################

helm install allpay-background-service ./allpay-background-service -f ./allpay-background-service/values.dev.yaml -n allpay-dev

helm install allpay-mq-service ./allpay-mq-service -f ./allpay-mq-service/values.dev.yaml -n allpay-dev

helm install allpay-web ./allpay-web -f ./allpay-web/values.dev.yaml -n allpay-dev

helm install allpay-webapi ./allpay-webapi -f ./allpay-webapi/values.dev.yaml -n allpay-dev

helm install vendor-portal-web ./vendor-portal-web -f ./vendor-portal-web/values.dev.yaml -n allpay-dev

helm install vendor-portal-webapi ./vendor-portal-webapi -f ./vendor-portal-webapi/values.dev.yaml -n allpay-dev
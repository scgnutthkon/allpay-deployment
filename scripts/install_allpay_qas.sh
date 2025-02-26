SCRIPT_DIR="$(dirname "$(realpath "$0")")"

cd "$SCRIPT_DIR/../"

##############################################################################
##Config apt proxy

# Proxy Env

#proxyUrl="http://10.100.12.240:6969/"
proxyUrl="http://CADAllpayVendor05:Avd%40%400513579@proxy-server.scg.com:3128/"
proxyEsp=$(echo $proxyUrl | sed s/%/%%/g)

export http_proxy="$proxyUrl"
export https_proxy="$proxyUrl"
export ftp_proxy="$proxyUrl"
export no_proxy=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.scg.com

# Create Namespace
kubectl create namespace allpay-qas

##########################Install redis#################################
kubectl apply -f ./redis/pv-qas.yaml

helm install allpay-redis bitnami/redis -f ./redis/values.qas.yaml -n allpay-qas

##########################Install RabbitMQ#################################
kubectl apply -f ./rabbitmq/pv-qas.yaml

helm install allpay-rabbitmq bitnami/rabbitmq -f ./rabbitmq/values.qas.yaml -n allpay-qas

##########################Install JS Report#################################
kubectl apply -f ./jsreport/pv-qas.yaml

helm install jsreport ./jsreport -f ./jsreport/values.qas.yaml -n allpay-qas

##########################Create App Namespace PV & PVC#################################
# Create PV
kubectl apply -f ./allpay-pv/allpay-qas-pv.yaml
# Create PVC
kubectl apply -f ./allpay-pv/allpay-qas-pvc.yaml -n allpay-qas

##########################Install Allpay Apps#################################
 helm upgrade allpay-dbmigration allpay-charts/allpay-dbmigration -f ~/deployment/allpay-dbmigration/values.qas.yaml -n allpay-qas --insecure-skip-tls-verify

helm install allpay-background-service ./allpay-background-service -f ./allpay-background-service/values.qas.yaml -n allpay-qas

helm install allpay-mq-service ./allpay-mq-service -f ./allpay-mq-service/values.qas.yaml -n allpay-qas

helm install allpay-web ./allpay-web -f ./allpay-web/values.qas.yaml -n allpay-qas

helm install allpay-webapi ./allpay-webapi -f ./allpay-webapi/values.qas.yaml -n allpay-qas

helm install vendor-portal-web ./vendor-portal-web -f ./vendor-portal-web/values.qas.yaml -n allpay-qas

helm install vendor-portal-webapi ./vendor-portal-webapi -f ./vendor-portal-webapi/values.qas.yaml -n allpay-qas
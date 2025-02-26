cd ~

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

##########################Initial Kube Cluster#################################
sudo kubeadmin init --node-name=master

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#########################Install Cilium#######################################
cilium install --set routingMode=native --set autoDirectNodeRoutes=true --set ipv4NativeRoutingCIDR=10.96.0.0/16

#########################Install Ingress Controller###########################
kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v4.0.1/deploy/crds.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/baremetal/deploy.yaml

kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
#kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/baremetal/deploy.yaml

#########################Install State Metrics################################
helm install kube-state-metrics bitnami/kube-state-metrics --version 4.3.4 -n kube-system

kubectl apply -f metricbeat-kubernetes.yaml -n kube-system
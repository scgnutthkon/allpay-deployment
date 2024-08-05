cd ~

##############################################################################
##Config apt proxy

# Proxy Env
export http_proxy="http://CADAllpayVendor03:Avd%40%400313579@172.30.1.22:3128/"
export https_proxy="http://CADAllpayVendor03:Avd%40%400313579@172.30.1.22:3128/"
export ftp_proxy="http://CADAllpayVendor03:Avd%40%400313579@172.30.1.22:3128/"
export no_proxy=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

sudo cat << EOF > /etc/apt/apt.conf.d/proxy.conf
Acquire::http::Proxy "http://CADAllpayVendor03:Avd%40%400313579@172.30.1.22:3128/";
Acquire::https::Proxy "http://CADAllpayVendor03:Avd%40%400313579@172.30.1.22:3128/";
EOF

##Upgrade packages
echo 'Upgrade packages................'
sudo apt update
sudo apt upgrade -y

###################################################################################################################
# Install docker
echo 'Installing Docker.................'
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
####################################################################################################################

##Modify contained config
sudo containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/g' > config.toml
sudo cp config.toml

###Disable Linux swap
sudo sed -i s/'^ *\/swap'/'#\/swap'/g /etc/fstab

###################################################################################################################

##Install Kubernetes
echo 'Installing Kubernates.................'
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly

sudo apt-get update
sudo apt-get install -y kubectl kubelet kubeadm

################################################################################################################
#### add proxy config to services
cat << EOF > http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://CADAllpayVendor03:Avd%%40%%400313579@proxy-server.scg.com:3128/"
Environment="HTTPS_PROXY=http://CADAllpayVendor03:Avd%%40%%400313579@proxy-server.scg.com:3128/"
Environment="NO_PROXY=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,10.100.12.93/24"
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo mkdir -p /etc/systemd/system/containerd.service.d
sudo cp http-proxy.conf /etc/systemd/system/docker.service.d
sudo cp http-proxy.conf /etc/systemd/system/containerd.service.d

######################################################################################################
### Install Helm
echo 'Installing Helm.................'
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

### Install Cilium
echo 'Installing Cilium.................'
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}


echo 'Please restart server'
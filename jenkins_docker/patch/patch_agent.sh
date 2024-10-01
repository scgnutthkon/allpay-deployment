echo "Creating config /etc/systemd/system/docker.service.d/http-proxy.conf"
#proxyUrl="http://10.100.12.240:6969/"
proxyUrl="http://CADAllpayVendor02:Avd%40%400213579@proxy-server.scg.com:3128/"
proxyEsp=$(echo $proxyUrl | sed s/%/%%/g)

if [ ! -d "/etc/systemd/system/docker.service.d" ]; then
    mkdir "/etc/systemd/system/docker.service.d"
fi

cat << EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$proxyEsp"
Environment="HTTPS_PROXY=$proxyEsp"
Environment="NO_PROXY=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.scg.com"
EOF

chmod 644 /etc/systemd/system/docker.service.d/http-proxy.conf

if [ ! -d "/home/jenkins/.docker" ]; then
    mkdir "/home/jenkins/.docker"
    chown jenkins /home/jenkins/.docker
    chgrp jenkins /home/jenkins/.docker
fi

echo "Creating config /home/jenkins/.docker/config.json"

cat << EOF > /home/jenkins/.docker/config.json
{
 "proxies": {
    "default": {
        "httpProxy": "$proxyUrl",
        "httpsProxy": "$proxyUrl",
        "noProxy": "127.0.0.1,10.100.12.94,10.100.12.93"
    }
 }
}
EOF

chown jenkins /home/jenkins/.docker/config.json
chgrp jenkins /home/jenkins/.docker/config.json

chmod 664 /home/jenkins/.docker/config.json

echo "Config git for using proxy"

su -c "git config --global http.proxy $proxyUrl" jenkins
su -c "git config --global https.proxy $proxyUrl" jenkins


cat << EOF > /home/jenkins/prepare_pipeline.sh
export http_proxy=$proxyUrl
export https_proxy=$proxyUrl
git config --global http.proxy $proxyUrl
git config --global https.proxy $proxyUrl
curl https://www.bbc.com > /dev/null
EOF

chown jenkins /home/jenkins/prepare_pipeline.sh
chgrp jenkins /home/jenkins/prepare_pipeline.sh

chmod 764 /home/jenkins/prepare_pipeline.sh
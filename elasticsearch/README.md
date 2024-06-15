# ElasticSearch Deployment
### Helm Commands
Generate kubernetes manifest file for elasticsearch
```sh
helm template elasticsearch elastic/elasticsearch -f elasticsearch.yaml -n elk > dep_elastic.yaml
```
Generate kubernetes manifest file for kibana
```sh
helm template kibana elastic/kibana -f kibana.yaml -n elk > dep_kibana.yaml
```
Install elasticsearch
```sh
helm install elasticsearch elastic/elasticsearch -f elasticsearch.yaml -n elk
```
Upgrade elasticsearch
```sh
helm install elasticsearch elastic/elasticsearch -f elasticsearch.yaml -n elk
```
Uninstall elasticsearch
```sh
helm uninstall elasticsearch -n elk
```
### APIs Command
Get service token
```sh
curl -k -u username:pass -X POST "https://localhost:9200/_security/service/elastic/kibana/credential/token" -H "Content-Type: application/json"
```
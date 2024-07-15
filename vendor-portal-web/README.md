# Vendor Portal Web Helm Chart

This Helm chart is used to deploy the Vendor Portal Web application to a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.30+
- Helm 3.15+

## Clone Charts from repository

```bash
git clone https://github.com/CADGithubMGR/allpay-deployment.git
```
Enter to repo directory.
```bash
cd allpay-deployment
```
## Pre-Insallation
Before install chart must create `namespace`, `pv` and `pvc` if not exist. The manifest file store in `./allpay-pv`.
<br/>Example for create `namespace`, `pv` and `pvc` for environment dev.
```bash
# Create Namespace
kubectl create namespace allpay-dev
# Create PV
kubectl apply -f ./allpay-pv/allpay-dev-pv.yaml
# Create PVC
kubectl apply -f ./allpay-pv/allpay-dev-pv.yaml
```

## Installation

To install the chart with the release name `vendor-portal-web`:

#### Environment Dev

```bash
helm install vendor-portal-web ./vendor-portal-web -f ./vendor-portal-web/values.dev.yaml -n allpay-dev
```
#### Environment QAS

```bash
helm install vendor-portal-web ./vendor-portal-web -f ./vendor-portal-web/values.qas.yaml -n allpay-qas
```

The command deploys the Vendor Portal Web on the Kubernetes cluster. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Upgrade

To upgrade chart with the release name `vendor-portal-web`:

#### Environment Dev

```bash
helm upgrade vendor-portal-web ./vendor-portal-web -f ./vendor-portal-web/values.dev.yaml -n allpay-dev
```
#### Environment QAS

```bash
helm upgrade vendor-portal-web ./vendor-portal-web -f ./vendor-portal-web/values.qas.yaml -n allpay-qas
```

The command upgrade the Vendor Portal Web on the Kubernetes cluster.

## Uninstallation

To uninstall/delete the `vendor-portal-web` deployment:

#### Environment Dev

```bash
helm uninstall vendor-portal-web -n allpay-dev
```
#### Environment QAS

```bash
helm uninstall vendor-portal-qas -n allpay-qas
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following table lists the configurable parameters of the Vendor Portal Web chart and their default values.

| Parameter                        | Description                                                  | Default                   |
|----------------------------------|--------------------------------------------------------------|---------------------------|
| `image.repository`               | Image repository                                             | `allpay-registry.scg.com/vendor-portal-web-[env]` |
| `image.tag`                      | Image tag                                                    | `latest`                  |
| `image.pullPolicy`               | Image pull policy                                            | `IfNotPresent`            |
| `replicaCount`                   | Number of replicas                                           | `1`                       |
| `service.type`                   | Kubernetes service type                                      | `ClusterIP`               |
| `service.port`                   | Service port                                                 | `3000`                    |
| `ingress.enabled`                | Enable ingress controller resource                           | `false`                   |
| `ingress.annotations`            | Ingress annotations                                          | `{}`                      |
| `ingress.hosts`                  | Ingress hostnames                                            | `[]`                      |
| `ingress.tls`                    | Ingress TLS configuration                                    | `[]`                      |
| `resources`                      | CPU/Memory resource requests/limits                          | `{}`                      |
| `nodeSelector`                   | Node labels for pod assignment                               | `{}`                      |
| `tolerations`                    | Tolerations for pod assignment                               | `[]`                      |
| `affinity`                       | Map of node/pod affinities                                   | `{}`                      |
| `env`                            | Environment variables for the container                      | `{}`                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install vendor-portal-web ./vendor-portal-web --set image.tag=1.2.3,replicaCount=2
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example:

```bash
helm install vendor-portal-web ./vendor-portal-web -f values.yaml
```

## Values Files

The `values.yaml` file contains the default configuration values for the chart. These values can be overridden by creating a `custom-values.yaml` file and passing it to the `helm install` command:

```bash
helm install vendor-portal-web ./vendor-portal-web -f custom-values.yaml
```

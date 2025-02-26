## For fix issue SSL Medium Strength Cipher Suites Supported (SWEET32)-Synopsis:

1. Edit Kubernetes API server manifest (usually located at `/etc/kubernetes/manifests/kube-apiserver.yaml`).

2. Add or update the `--tls-cipher-suites` flag, specifying only strong ciphers. For example:

```yaml
spec:
  containers:
    - name: kube-apiserver
      command:
        - kube-apiserver
        - --tls-cipher-suites=TLS_AES_256_GCM_SHA384,TLS_AES_128_GCM_SHA256,TLS_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
```
3. Save the file and restart the Kubernetes:
```bash
sudo systemctl restart kubelet
```
### Verify Changes:
After applying the changes, verify that weak ciphers are disabled using OpenSSL:

```bash
openssl s_client -connect <your_host>:6443 -cipher ECDHE-RSA-DES-CBC3-SHA
```
If the connection fails, the weak cipher has been successfully disabled.

---


# slide_server proof of concept


- Running with gcsfuse
```

rm -r public
mount  gcsfuse  --implicit-dirs cgc-05-0036-misc public
ruby viewer.rb

```


- Kubernetes

```

# [HOSTNAME]/[PROJECT-ID]/[IMAGE][:TAG]
gcloud projects list
gcloud config list

# start Kubernetes
gcloud container clusters create slideserver \
    --num-nodes 1 \
    --machine-type g1-small

gcloud docker -- push gcr.io/yet-another-project-179304/slideserver:v1
kubectl  run slideserver  --image=gcr.io/yet-another-project-179304/slideserver  --port=8080
kubectl expose deployment slideserver --type="LoadBalancer"
kubectl get services slideserver


```

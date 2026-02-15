# Create the base yaml for each resource

```
kubectl create deploy web --image public.ecr.aws/nginx/nginx:1.29-alpine-amd64 --dry-run=client -o yaml
kubectl create service clusterip web --tcp 80:80 --dry-run=client -o yaml
kubectl create ingress web --rule="/=web:80" --dry-run=client -o yaml
```

Add these annotations to the ingress
```
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
```

# Goals for each resource

## Deployment

- Rolling updates to ensure the service never goes down
- Open port 80 on the container to enable internet access
- Define both cpu and memory requests and limits
  - cpu: "50m"
  - memory: "64Mi"
- Define a startup probe to ensure service is healthy

## Service

- Ensure it uses the selector label for the pods
- Enable access to and from port 80

## Ingress

- Route traffic to the path `/` to the services port `80`

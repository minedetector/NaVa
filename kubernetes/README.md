To be able to complete the kubernetes lab download [kubectl from here](https://kubernetes.io/docs/tasks/tools/)

To access the k8s cluster you'll need to configure `Security Credentials` for AWS
- Steps described in the [serverless-lab readme step 1](https://github.com/minedetector/NaVa/blob/main/infrastructure/serverless-lab/README.md)

Configure your access to AWS using either `aws configure` and copy-pasting the info (we are in region `eu-north-1`) or
set the ENV variables to your terminal session like this
```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

Once the connection has been configured run the following command to add the `nava` cluster to your k8s config
```
aws eks update-kubeconfig --region eu-north-1 --name nava
```

To test out that it work run the following command
```
kubectl get pods -A
```

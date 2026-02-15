export CLUSTER_NAME="nava"
export REGION="eu-north-1"
export AWS_PAGER=""

for i in {1..38}; do
  USER="arn:aws:iam::187833180667:user/tiim_$i"

  aws --profile nava-admin eks create-access-entry \
    --cluster-name $CLUSTER_NAME \
    --principal-arn $USER \
    --type STANDARD \
    --region $REGION

  aws --profile nava-admin eks associate-access-policy \
    --cluster-name $CLUSTER_NAME \
    --principal-arn $USER \
    --region $REGION \
    --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy \
    --access-scope type=namespace,namespaces="tiim-$i"

    aws --profile nava-admin eks associate-access-policy \
    --cluster-name $CLUSTER_NAME \
    --principal-arn $USER \
    --region $REGION \
    --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy \
    --access-scope type=cluster
done;

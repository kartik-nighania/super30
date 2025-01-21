

# create and upload image to ECR
aws_account_id=$(aws sts get-caller-identity --query Account --output text)
aws ecr create-repository --repository-name locust
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.ap-south-1.amazonaws.com


docker build --platform=linux/amd64 -f ./Dockerfile -t locust:latest .
docker tag locust:latest ${aws_account_id}.dkr.ecr.ap-south-1.amazonaws.com/locust:latest
docker push ${aws_account_id}.dkr.ecr.ap-south-1.amazonaws.com/locust:latest

echo "ECR URI: ${aws_account_id}.dkr.ecr.ap-south-1.amazonaws.com/locust:latest"
echo "update deployment with ECR URI"

# the below command will replace the <ECR_URI> with the actual ECR URI in memory and run it
deployment=$(cat ./deployment-locust.yaml | sed "s|<ECR_URI>|${aws_account_id}.dkr.ecr.ap-south-1.amazonaws.com/locust:latest|g")
echo "$deployment" | kubectl apply -f -

kubectl apply -f service-locust.yaml
kubectl apply -f ingress-locust.yaml
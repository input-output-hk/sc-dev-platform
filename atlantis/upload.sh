docker build -t scde . --platform=linux/amd64

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 677160962006.dkr.ecr.us-east-1.amazonaws.com

docker tag scde:latest 677160962006.dkr.ecr.your-region.amazonaws.com/scde:latest

docker push 677160962006.dkr.ecr.us-east-1.amazonaws.com/scde:latest
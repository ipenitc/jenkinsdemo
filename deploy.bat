@echo off
SET IMAGE_NAME=ipenitcdocker/jenkinsdemo:latest
SET CONTAINER_NAME=jenkins-demo-app

echo --- Stopping existing container ---
docker stop %CONTAINER_NAME% 2>nul
docker rm %CONTAINER_NAME% 2>nul

echo --- Pulling latest image from Docker Hub ---
docker pull %IMAGE_NAME%

echo --- Starting new container ---
docker run -d ^
  --name %CONTAINER_NAME% ^
  -p 8081:8081 ^
  %IMAGE_NAME%

echo --- Deployment Complete ---
echo App is running at http://localhost:8081
pause
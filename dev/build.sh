#!/bin/bash
docker build -t testdev1 -f Dockerfile_dev .
if [ $? -eq 0 ]; then
     docker run  -it --rm testdev1 bash ./action.sh
fi
  


there things should be done by running this script with related files and actions.
1, create one Jenkins server which can be accessed outside.
   the Jenkins should be in POD
   the pipeline can be created and built automatically.
   after build the Docker image will be updated into image server normally.
   trigger the script about the package installation
2, create dev server to build program by, build.sh.
3, deloy server by the package from step one.

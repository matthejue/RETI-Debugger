<div align="center">
<a href="https://github.com/freiburg-missing-semester-course/project-matthejue">
  <img src="./misc/logo7.png" alt="Logo" height="100px">
</a>
</div>

# Running in a Docker Image

This is the recommended way of testing this plugin if you want to run the plugin in a clean sandbox without disturbances of any kind. Just use the `Dockerfile` in the repository. Therefore execute the following commands in the main folder of the repository to build an image and run the image as a container:

```bash
sudo docker build . -t reti_debugger_test_environment
sudo docker run -it --rm reti_debugger_test_environment /bin/bash

# in the Docker container run:
nvim

# the plugin will install automatically once Neovim starts, you can start the plugin via:
:StartRETIBuffer

# if after testing you want to get rid of the image again just run
sudo docker image rm reti_debugger_test_environment
# and when running
sudo docker image ls
# the image is gone
```



[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/9FxAlQXs)

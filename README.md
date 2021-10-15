# Packer to automate Docker image creation and provisioning

For years I've been using `Makefile` to automate my docker workflows. After
writing my `Dockerfile` I would write all the automation code (`docker run` and
`docker build` recipes) in `make` targets. Anything passed from the host
environment would be a make variable, or I'd use a shell script to run
provisioning code once the container was created and run (e.g. create user
based on host `$USER` and mount their `~/` inside the container. 

The downside of `make` is 1) debugging is a nightmare 2) its not always clear
what variables are at run time 3) wrapping docker/shell/python with Makefile
can get ugly really quick. For small stuff its fine, and writing make is very
fast. But for anything large, it can become a nightmare to read and debug.

This project is an experiment to use Packer instead of Make, let Packer handle
all the image creation and container provisioning. I also wanted to experiment
with using Ansible instead of Packer's provisioning routes.



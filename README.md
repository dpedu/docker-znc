Docker ZNC
==========

Suitable for create docker containers running ZNC (and sshd!)

**General steps:**

* Install docker
* Clone this repo, cd in
* Load it as a template: `sudo docker build -t znc .`
* Start a new container: `sudo docker run -it -p 666:22 -p 4421:4421 znc /start`

On first start, the znc configuration will run. Set it up as needed; the port znc listens on must be exposed in the command used to start the container (-p 4421:4421 above). The final question asks if you want to start znc, **choose `NO`**. 

* Find the new container in your list: `sudo docker ps -a`
* Run it in the background: `sudo docker start mycontainerid`


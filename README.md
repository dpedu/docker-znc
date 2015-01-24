#Docker ZNC

Suitable for creating docker containers running ZNC. Now with pisg!

##Setup
**General steps:**

* Install docker
* Clone this repo, cd in
* Load it as a template: `sudo docker build -t znc .`
* Start a new container: `sudo docker run -it -p 666:22 -p 4421:4421 -p 80:80 znc /start`
* Configure znc
* Find the new container in your list: `sudo docker ps -a`
* Run it in the background: `sudo docker start mycontainerid`

When you first run the image, you'll be presented with two ways to configure znc: 

###Set up a new znc instance

If no import of existing znc data is available, the znc configuration will run. Set it up as needed; the port znc listens on must be exposed in the command used to start the container (-p 4421:4421 above). The final question asks if you want to start znc, **choose `NO`!!**. 

###Import an existing znc instance's configuration

You may migrate an existing ZNC instance into this container by providing a tarball of the source .znc directory. The tarball should contain the .znc directory, only, with everything inside it. The start script will prompt you to insert the .tar.gz file.

##Pisg

This container creates [pisg]-style channel statistics ([example]) for any ZNC users with the "log" module enabled. The stats are regenerated nightly and nginx serves the files on port 80 with a directory structure like this:

* znc username
  * znc network name
    * \#channelname.html

The channel information is private, nginx is configured with HTTP basic authentication; the password is prompted for during setup.

## TODO

* Ensure pisg cache files don't use too much disk space (/home/znc/pisg/cache)
  * If this is a problem, maybe tar/gz channel groups and extract when necessary when running pisg
* Provide a way to make certain channel stat files public 
* Provide a way to share channel files with secret links
* Provide all-time, yearly, and monthly pisg outputs
* Compile provided ZNC modules into the image

[pisg]:http://pisg.sourceforge.net/
[example]:http://pisg.sourceforge.net/examples

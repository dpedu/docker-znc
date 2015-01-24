FROM ubuntu:14.04
MAINTAINER Dave P

# Admin user
RUN useradd --create-home --groups sudo admin ; echo "admin:admin" | chpasswd ; locale-gen en
# ZNC user
RUN useradd --create-home znc ; echo "znc:znc" | chpasswd 

# Install sshd, znc, and znc extras
RUN mkdir /var/run/sshd ; apt-get update ; apt-get install -y supervisor vim openssh-server znc znc-python znc-dev dpkg-dev

# Get ZNC source
RUN su -c 'cd /home/znc ; apt-get source znc' znc

# Install startup stuff
COPY daemons.conf /etc/supervisor/conf.d/daemons.conf
COPY start /start
RUN chmod +x /start

# Ports
EXPOSE 22

# Pisg dir
RUN su -c 'mkdir /home/znc/pisg /home/znc/pisg/cache /home/znc/pisg/output' znc
# Pisg and nginx
RUN apt-get install -y pisg nginx-light
# Set nginx workers to a low number
RUN sed -i -e"s/^worker_processes\s*4/worker_processes 1/" /etc/nginx/nginx.conf
# Set nginx user to ZNC user
RUN sed -i -e"s/^user\s*www\-data/user znc/" /etc/nginx/nginx.conf
# Turn off nginx daemon mode
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# Set up nginx
COPY default /etc/nginx/sites-available/default
# Install crontab
COPY crontab /tmp/
RUN crontab -u znc /tmp/crontab
RUN rm /tmp/crontab
# Install stuff for log generation

COPY pisg.py /home/znc/pisg/
RUN chmod +x /home/znc/pisg/pisg.py

# Expose nginx
EXPOSE 80

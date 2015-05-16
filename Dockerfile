FROM dpedu/base
MAINTAINER Dave P

# ZNC user
RUN useradd --create-home znc ; echo "znc:znc" | chpasswd 

# Install sshd, znc, znc extras, nginx, pisg
RUN mkdir /var/run/sshd ; apt-get update ; apt-get install -y supervisor vim openssh-server znc znc-python znc-dev dpkg-dev pisg nginx-full irssi screen

# Get ZNC source
RUN su -c 'cd /home/znc ; apt-get source znc' znc

# Set nginx workers to a low number
RUN sed -i -e"s/^worker_processes\s*4/worker_processes 2/" /etc/nginx/nginx.conf
# Set nginx user to ZNC user
RUN sed -i -e"s/^user\s*www\-data/user znc/" /etc/nginx/nginx.conf
# Turn off nginx daemon mode
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# Set up nginx
COPY default /etc/nginx/sites-available/default

# Install pisg stuff for log generation
RUN su -c 'mkdir /home/znc/pisg /home/znc/pisg/cache /home/znc/pisg/output /home/znc/pisg/output/.pub' znc
COPY pisg.py /home/znc/pisg/
RUN chmod +x /home/znc/pisg/pisg.py ; chown znc /home/znc/pisg/pisg.py

# Install crontab
COPY crontab /tmp/
RUN crontab -u znc /tmp/crontab
RUN rm /tmp/crontab

# Install startup stuff
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY znc.conf /etc/supervisor/conf.d/znc.conf
COPY sshd.conf /etc/supervisor/conf.d/sshd.conf
COPY start /start
RUN chmod +x /start

# ssh
EXPOSE 22
# nginx
EXPOSE 80

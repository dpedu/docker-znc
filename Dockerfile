FROM ubuntu:trusty

#RUN echo 'Acquire::http::Proxy "http://172.17.0.3:3128";' > /etc/apt/apt.conf

# Admin user
RUN useradd --create-home --groups sudo admin ; echo "admin:admin" | chpasswd ; locale-gen en_US en_US.UTF-8
# ZNC user
RUN useradd --create-home znc ; echo "znc:znc" | chpasswd 

# Install sshd, znc, znc extras, nginx, pisg
RUN mkdir /var/run/sshd ; apt-get update ; apt-get install -y supervisor vim openssh-server znc znc-python znc-dev dpkg-dev pisg nginx-full irssi screen ; rm /etc/ssh/ssh_host_* ; mkdir /etc/ssh/keys ; sed -i -E 's/HostKey \/etc\/ssh\//HostKey \/etc\/ssh\/keys\//' /etc/ssh/sshd_config

# Get ZNC source
RUN su -c 'cd /home/znc ; apt-get source znc' znc ; mkdir /srv/znc ; chown znc:znc /srv/znc

# Set nginx workers to a low number
RUN sed -i -e"s/^worker_processes\s*4/worker_processes 1/" /etc/nginx/nginx.conf
# Set nginx user to ZNC user
RUN sed -i -e"s/^user\s*www\-data/user znc/" /etc/nginx/nginx.conf
# Turn off nginx daemon mode
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# Set up nginx
COPY default /etc/nginx/sites-available/default

# Install pisg stuff for log generation
COPY pisg.py /usr/local/bin/pisg.py
RUN chmod +x /usr/local/bin/pisg.py

# Install crontab
COPY crontab /tmp/
RUN crontab -u znc /tmp/crontab
RUN rm /tmp/crontab

# Install startup stuff
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY nginx.conf /etc/supervisor/conf.d/nginx.conf
COPY cron.conf /etc/supervisor/conf.d/cron.conf
COPY znc.conf /etc/supervisor/conf.d/znc.conf
COPY sshd.conf /etc/supervisor/conf.d/sshd.conf
COPY start /start
RUN chmod +x /start

VOLUME ["/srv/znc", "/etc/ssh/keys"]

# ssh
EXPOSE 22
# nginx
EXPOSE 80

ENTRYPOINT ["/start"]

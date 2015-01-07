FROM ubuntu:14.04
MAINTAINER Dave P

# Admin user
RUN useradd --create-home --groups sudo admin ; echo "admin:admin" | chpasswd ; locale-gen en
# ZNC user
RUN useradd --create-home znc ; echo "znc:znc" | chpasswd 

# Install bind and vim
RUN mkdir /var/run/sshd ; apt-get update ; apt-get install -y supervisor vim openssh-server znc znc-python znc-dev dpkg-dev

# Get ZNC source
RUN su -c 'cd /home/znc ; apt-get source znc' znc

COPY daemons.conf /etc/supervisor/conf.d/daemons.conf
COPY start /start
#EXPOSE 53/udp
EXPOSE 22
RUN chmod +x /start


#!/usr/bin/env python3
import subprocess
from os import listdir,unlink,chdir,mkdir
from os.path import exists
from sys import exit
from random import randint

class logfile:
    def __init__(self, username, network, channel):
        self.username = username
        self.network = network
        self.channel = channel
        self.path = "/home/znc/.znc/users/%s/moddata/log/%s_%s" % (self.username, self.network, self.channel)
    
    def __str__(self):
        return "<logfile username=%s network=%s channel=%s path=%s>" % (self.username, self.network, self.channel, self.path)
    
    def generate_config(self):
        return """<set ShowMostActiveByHour="1">
<set ShowMostActiveByHourGraph="1">
<set ActiveNicksByHour="15">
<set ShowTime="1">
<set ShowLines="1">
<set ShowWpl="1">
<set ShowWords="1">
<set ShowLineTime="1">
<set ShowSmileys="1">
<set ShowKarma="1">
<set KarmaHistory="15">
<set TopicHistory="25">
<set PicLocation="/gfx">
<set UserPics="1">
<set ActiveNicks="50">
<set CacheDir="/home/znc/pisg/cache">
<set FoulWords="shit piss fuck cunt cocksucker motherfucker tits fag faggot nigger">

<channel="%(channel)s">
   Logfile = "%(logdir)s_*.log"
   Format = "energymech"
   Network = "%(network)s"
   OutputFile = "/home/znc/pisg/output/%(username)s/%(network)s/%(channel)s.html"
</channel>""" % {"logdir":self.path, "network":self.network, "channel":self.channel, "username":self.username}
    
    def run_pisg(self):
        if not exists("/home/znc/pisg/output/%s" % self.username):
            mkdir("/home/znc/pisg/output/%s" % self.username)
        if not exists("/home/znc/pisg/output/%s/%s" % (self.username, self.network)):
            mkdir("/home/znc/pisg/output/%s/%s" % (self.username, self.network))
        configname = "config.%s" % str(randint(0,10000))
        open(configname, "w").write(self.generate_config())
        proc = subprocess.Popen(['pisg',"-co", configname], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(self.path +": "+str(proc.communicate()))
        unlink(configname)

if __name__ == "__main__":
    chdir("/home/znc/pisg")
    logs = []
    for user in listdir("/home/znc/.znc/users/"):
        if not exists("/home/znc/.znc/users/%s/moddata/log/" % user):
            continue
        
        networks = {}
        
        for fname in listdir("/home/znc/.znc/users/%s/moddata/log/" % user):
            network, parts = fname.split("_", 1)
            if not network in networks:
                networks[network]=[]
            channel, parts = parts.rsplit("_", 1)
            if "#" in channel and not channel in networks[network]:
                networks[network].append(channel)
            
        print(user)
        print(networks)
        for network in networks:
            for channel in networks[network]:
                logs.append(logfile(user, network, channel))
    
    for log in logs:
        log.run_pisg()

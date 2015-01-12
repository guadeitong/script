#!/usr/bin/env python

from fabric.api import env,local,run
from fabric.contrib.project import rsync_project

env.password='1234abcd'
env.hosts='192.168.2.8'
env.user='root'
env.port='22'

def ls():
    run("ls")
    rsync_project(local_dir='/home/radio/index.html',remote_dir='~/')

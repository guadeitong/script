#!/usr/bin/env python

from fabric.api import env,run,cd,put,local
import fabric.colors
import os

env.color_settings = {
    'abort': yellow,
    'error': yellow,
    'finish': cyan,
    'host_prefix': green,
    'prefix': red,
    'prompt': blue,
    'task': red,
    'warn': yellow
}

env.roledefs = {
    'adr_ct': ['54.254.227.238',
               '54.251.169.252',
               '54.254.225.44',
               '54.254.243.75',
               '54.255.197.11',
               '54.179.157.205',
               '54.255.144.200'],

    'ios_ct': ['122.248.239.224',
               '122.248.239.247',
               '122.248.239.254',
               '122.248.240.19',
               '46.137.248.14',
               '54.251.33.62', 
               '54.251.38.110',
               '54.251.112.128', 
               '54.251.36.44',
               '54.251.101.194',
               '54.251.36.239',
               '122.248.254.128',
               '54.254.96.198',
               '54.251.114.11',
               '54.251.114.247',
               '54.251.117.67']
}

env.config_file = 'deploy.yaml'
#env.hosts=open('hosts.txt','r').readlines()
env.user='lzadmin'
env.port='4399'
env.password=''

@roles('adr_ct')
@roles('ios_ct')
def init():
    local("echo pwd")
    filename=r''
    if os.path.exists(filename):
        task
    else:
        print "there is no file that you can putting"

def task():
    with cd('~/')
    put('./filename','./filename')



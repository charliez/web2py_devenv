#!/usr/bin/env bash

## Run this script with sudo after setup-web2py-nginx-uwsgi-ubuntu.sh
## inside your Vagrant machine.
##
## Set a web2py development environment inside a Vagrant box.
##
## This script does these:
## 1. sets "vagrant" as user for nginx and uwsgi
## 2. sets $HOME and $PATH environment variables for web2py.
## 3. let "vagrant" own the filesystem where your application is located.
##
## by @viniciusban



if [ ! -f "/etc/uwsgi/web2py.ini" ]; then
    echo "Missing web2py configuration for uwsgi."
    echo "You must run setup-web2py-nginx-uwsgi-ubuntu.sh before."
    exit 1
fi


## run ngingx with user vagrant.

cd /etc/nginx
sudo sed -i.original 's/^user www-data/user vagrant/' nginx.conf


## run uwsgi with user vagrant.

cd /etc/uwsgi
sudo sed -i.original 's/www-data$/vagrant/' web2py.ini


## set ownership of web2py runtime directory to user vagrant.

sudo chown -R vagrant:vagrant /home/www-data/web2py


## create a symbolic link to run your app

appname=$(cat /etc/hostname)
ln -s /vagrant/src /home/www-data/web2py/applications/$appname


## create a /etc/init/uwsgi-emperor.override in /etc/init

echo '# Emperor uWSGI script

description "uWSGI Emperor"
start on runlevel [2345]
stop on runlevel [06]
respawn

script
    export HOME="/home/vagrant"
    export PATH="/home/vagrant/bin":$PATH
    exec uwsgi --master --die-on-term --emperor /etc/uwsgi --logto /var/log/uwsgi/uwsgi.log
end script
' | sudo tee /etc/init/uwsgi-emperor.override > /dev/null

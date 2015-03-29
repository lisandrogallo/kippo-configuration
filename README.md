Kippo Configuration
===================

Custom settings and configurations I used in my Kippo's honeypots.

## Prepare the underlying OS

Assuming that it is a **Debian/Ubuntu** OS.

### Install requirements

    sudo aptitude update
    sudo aptitude install ssh build-essential python-dev libmysqlclient-dev \
    python-pip iptables-persistent screen

    pip install twisted pyasn1 pycrypto MySQL-python virtualenv virtualenvwrapper

### Setup virtualenv

Edit your **~/.profile** file and add this two lines:

    export WORKON_HOME=$HOME/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh

Load the new configuration and create the virtualenv:

    source ~/.profile
    mkvirtualenv kippo

### Setup SSH service

Normally sshd service listens on default port 22/TCP. But we will use this port for the SSH honeypot so we need to change the default port. Kippo comes pre-configured with port 2222/TCP, because it needs to run as non-privilege user and non-privileged user is not able to open any ports below number 1024. So later we will create an iptables rule to redirect from port 22 to 2222. Now we will choose an alternative port for the sshd service in other to access to our honeypot's underlying system. Edit **/etc/ssh/sshd_config** and modify the following lines:

    Port 50022
    PermitRootLogin no

### Setup firewall

We need to have some iptables rules in place in order to redirect SSH connections to port 2222/TCP (Kippo default port):

    sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222

Also, it could be useful to configure default INPUT chain policy to **DROP** and accept connections only from specific sources based in geolocation. Using the service at **IP2Location** (http://www.ip2location.com/blockvisitorsbycountry.aspx) you can select a country and export the IPv4/IPv6 rules to use with iptables.

On this repo I included a **/etc/iptables/rules.v4** file including Argentina's IP address ranges to be used with the **iptables-persistent** package previously installed.

## Install and configure Kippo

### Clone the repo

    git clone https://github.com/desaster/kippo.git

### Filesystem configuration

By default Kippo comes with its own filesystem but you can clone your own filesystem (without revealing any sensitive information):

    sudo kippo/utils/createfs.py > kippo/fs.pickle

### Alternative root passwords

Kippo comes with pre-configured password '123456'. We will add more passwords:

    kippo/utils/passdb.py kippo/data/pass.db add password
    kippo/utils/passdb.py kippo/data/pass.db add 12345
    kippo/utils/passdb.py kippo/data/pass.db add 1234
    kippo/utils/passdb.py kippo/data/pass.db add 123
    kippo/utils/passdb.py kippo/data/pass.db add root
    kippo/utils/passdb.py kippo/data/pass.db add qwerty
    kippo/utils/passdb.py kippo/data/pass.db add admin

### Kippo start script

Backup the original Kippo start script and download the alternative **start.sh** included on this repo. It has been modified to support virtualenv with **virtualenvwrapper** and to do full packet capture using **tcpdump** (this could provide additional information on the connections being made).

Edit the **start.sh** included on this repo and modify the following variables accordingly to your setup:

    WORKON_HOME=$HOME/.virtualenvs/
    NETWORK="192.168.1.0/24"
    CAPTURE_PATH="/mnt/kippo.cap"

## Run Kippo

Finally, start Kippo:

    cd kippo
    ./start.sh kippo

To reattach to the tcpdump process running inside a **screen** session, for monitoring purposes or terminating the command, do the following:

    screen -r tcpdump

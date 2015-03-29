#!/bin/sh

set -e

WORKON_HOME=$HOME/.virtualenvs/
NETWORK="192.168.1.0/24"

cd $(dirname $0)

if [ "$1" != "" ]
then
    VENV="$WORKON_HOME$1"

    if [ ! -d "$VENV" ]
    then
        echo "The specified virtualenv \"$VENV\" was not found!"
        exit 1
    fi

    if [ ! -f "$VENV/bin/activate" ]
    then
        echo "The specified virtualenv \"$VENV\" was not found!"
        exit 2
    fi

    echo "Activating virtualenv \"$VENV\""
    . $VENV/bin/activate
fi

twistd --version

echo "Starting kippo in the background..."
twistd -y kippo.tac -l log/kippo.log --pidfile kippo.pid

echo "Starting tcpdump inside a screen session. Run 'screen -r tcpdump' to reattach. "
screen -S "tcpdump" -dm sudo tcpdump -i eth0 tcp and not src net $NETWORK and not src localhost -w /mnt/kippo.cap &

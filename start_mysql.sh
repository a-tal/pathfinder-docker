#!/bin/bash

function wait_for() {
    SERVICE=$1
    PORT=$2
    HOST=${3-localhost}
    bash -c "cat < /dev/null > /dev/tcp/$HOST/$PORT"
    while [[ $? != 0 ]]; do
        echo "waiting for $SERVICE at $HOST to online..."
        sleep 1
        bash -c "cat < /dev/null > /dev/tcp/$HOST/$PORT"
    done
    echo "connected to $SERVICE on $HOST port $PORT"
}

service mysql restart
wait_for mysql 3306

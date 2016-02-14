#!/bin/bash

# Creating FIFO special file for controlling input to omxplayer
if [ ! -e /tmp/omxplayer.pipe ]
then
        mkfifo /tmp/omxplayer.pipe
fi

# Executing player
( omxplayer -b -o hdmi "$1" < /tmp/omxplayer.pipe & )

# Initialize
echo -n . /tmp/omxplayer.pipe
clear

# Waiting for input from CEC / HDMI
while read line; do

        cmd=$(echo $line | grep -oh ">> [0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]$" | awk '{print $2}')

        case $cmd in
		# quitting
                01:8b:0d)
                        echo "Quiting"
                        echo -n q > /tmp/omxplayer.pipe
                        rm /tmp/omxplayer.pipe
                        break
                        ;;
		# pause/play using 'OK' button
                01:8b:00)
                        echo -n 'p' > /tmp/omxplayer.pipe
                        ;;
		# forward using left arrow
                01:8b:03)
                        echo -n "^[[D" > /tmp/omxplayer.pipe
                        ;;
		# forward using right arrow
                01:8b:04)
                        echo -n "^[[C" > /tmp/omxplayer.pipe
                        ;;
        esac

done < <(cec-client)

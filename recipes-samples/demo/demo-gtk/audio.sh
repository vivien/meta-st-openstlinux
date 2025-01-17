#!/bin/sh
source /etc/profile.d/pulse_profile.sh

# this magic line permit to create the link to pulseaudio
script -qc 'su -l weston -c "source /etc/profile.d/pulse_profile.sh;pactl info; pactl list sinks"'

while [ 1 ]; do
    pactl info
    if [ $? -eq 0 ]; then
        break;
    else
        sleep 1;
    fi
done
if [ -f /usr/bin/pulseaudio_hdmi_switch.sh ]; then
    /usr/bin/pulseaudio_hdmi_switch.sh
else
    pactl info; pactl list sinks

    cards=`pactl list cards |  grep -i 'api.alsa.card.name' | sed 's/ //g'| sed 's/api.alsa.card.name=\"//g'| sed 's/\"//g'`
    index=0
    for i in $cards;
    do
        found=`echo $i | grep -n STM32MP | wc -l`
        if [ $found -eq 1 ];
        then
                index=$(echo \$i | sed 's/#//')
                pactl set-card-profile $index output:analog-stereo
        fi
        index=$((index+1))
    done
fi
# force pulseaudio sink and source to be on SUSPENDED state (cf: pactl list sinks)
pactl suspend-source 0
for sink in $(pactl list short sinks | awk '{ print $1 }'); do
        pactl suspend-sink $sink
done

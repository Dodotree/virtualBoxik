#!/bin/bash

source $(dirname $0)/boxikScripts/boxik_config

##Sets the for-loop delimiter to be only newlines, not whitespace. (Allows VM names with spaces)
IFS=$'\n'

##Only looks through the VM's of the user who ran this program.
for i in $(vboxmanage list vms | grep -oP "\"\K.*(?=\")");do
	VBoxManage guestproperty set "$i" /MyData/VMname "$i"
	VBoxManage guestproperty set "$i" /MyData/hostIP $HOST_IP
	VBoxManage guestproperty set "$i" /MyData/boxikListenPort $NC_PORT
done



#!/bin/bash

##This script depends on the user-id of the user that's running this, since it calls up virtualbox

((counter=$4+1))
i=1

while [ "$i" != "$counter" ];do
	vboxmanage clonevm "$1" --snapshot "$2" --name "$3$i" --register --options link &>/dev/null || ((counter=$counter+1))
	((i=$i+1))
done

##Allowing for Guest VM to Host VM communication, sets the netcat port etc.
$(dirname $0)/configVMNetwork.sh

#!/bin/bash

source $(dirname $0)/boxik_config
error_file=$(mktemp)

##Exit cleanup when the service is stopped
trap "rm $error_file;exit;" SIGHUP SIGINT SIGTERM

while true; do
	## Temp file to split stoud (the commands) and stderr(the listen/recieved from IP etc.)
	error_file=$(mktemp)
	com=$(nc -lvq 0 -p $NC_PORT 2>$error_file)
	err=$(< $error_file)
	##Prevent non-local (not from VM) command listing
	if ! [[ $err =~ $HOST_IP ]];then
		echo "$0: Authorization failure"
	else
		$(dirname $0)/manage.sh $com
	fi

done


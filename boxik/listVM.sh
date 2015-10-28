#!/bin/bash

com='vboxmanage list vms | grep -oP "\"\K.*(?=\")"'

for users in $(cut -d: -f1 /etc/passwd);do

	##Storing in array in case the name has spaces

	output=( $(su -l $users -c "$com" 2>/dev/null) )
	if ! [ -z "${output[0]}" ] && ! [[ ${output[@]} =~ "not available" ]];then
		echo -e $users"\t"${output[@]}
	fi
done


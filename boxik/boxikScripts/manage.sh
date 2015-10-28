#!/bin/bash

## Just runs the appropriate commands depending on input, open for further expansion.
while [ "$1" ]; do
	case $1 in
	
	updateIP)
		$(dirname $0)/host.sh "${@: 2}"
		exit;;

	*) 	
		echo "$0: Unrecognized command \"$1\"" >&2
            	exit 2;;

	esac
	shift
done

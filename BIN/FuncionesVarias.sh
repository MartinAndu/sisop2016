#!/bin/bash

function ambienteInicializado(){

	if [ "${GRUPO}" == "" ]; then	
		return 1
	fi

	if [ "${CONFDIR}" == "" ]; then	
		return 1
	fi

	if [ "${BINDIR}" == "" ]; then	
		return 1
	fi

	if [ "${MAEDIR}" == "" ]; then	
		return 1
	fi

	if [ "${OKDIR}" == "" ]; then	
		return 1
	fi

	if [ "${NOKDIR}" == "" ]; then	
		return 1
	fi

	if [ "${PROCDIR}" == "" ]; then	
		return 1
	fi

	if [ "${LOGDIR}" == "" ]; then	
		return 1
	fi	

	if [ "${ARRIDIR}" == "" ]; then	
		return 1
	fi

	if [ "${INFODIR}" == "" ]; then	
		return 1
	fi
	echo "Sds"
	return 0
}

function getPid(){
    local ppid=` ps aux | grep "\(/bin/bash\)\ $BINDIR/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
    echo $ppid
}

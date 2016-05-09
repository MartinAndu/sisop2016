#!/bin/bash



function ambienteInicializado(){
	i=0 
	variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR} ${INFODIR} ${LOGDIR} ${NOKDIR}) 
	for VAR in "${variables[@]}"
	do
		if [[ ! -z "$VAR" ]]; then # si la variable no está vacía es porque fue inicializado
		  ((i+=1))
		fi
	done

	if [ "$i" -gt 0 ]; then # Ambiente ya inicializado
		return 0
	fi

	return 1
}

function getPid(){
    local ppid=` ps aux | grep "\(/bin/bash\)\ $BINDIR/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
    echo $ppid
}

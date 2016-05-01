#! /bin/bash

# Detener de Scripts
# $1 script a detener
#########################  Procedimientos ##################################
source FuncionesVarias.sh

GRABITAC="$BINDIR/GrabarBitacora.sh"
comando=$1

function verificarComandoInvocado(){
	if [ ! -f $BINDIR/$comando.sh ]; then
    		local mensajeError="El comando ingresado es Incorrecto"
		imprimirResultado "$mensajeError" "ERR"
	fi
}

function verificarAmbiente(){
	if [ $comando != "PrepararAmbiente" ];then
		ambienteInicializado
		if [ $? == 1 ];then
			local mensajeError="Ambiente no inicializado"
			imprimirResultado "$mensajeError" "ERR"
		fi
	fi
}

function verificarProcesoCorriendo(){
	PID=$(getPid $comando)
	if [ -z $PID ];then
		local mensaje="$comandoAInvocar no esta corriendo"
		imprimirResultado "$mensaje" "WAR"
	fi
}

# $1 Mensaje $2 Tipo Mensaje
function imprimirResultado(){
	#se corrio por consola
	echo "$2: $1"
	exit
}


# funcion llamada por los scripts
function detener(){
	verificarComandoInvocado
	verificarAmbiente
	verificarProcesoCorriendo
	PID=$(getPid $comando)
	if [ "$PID" != "" ]; then
	    #log "INFO" "Deteniendo proceso con pid $PID .."
	    kill -9 $PID
	    
	    if [ $? -ne 0 ];
	    then
		echo "Error al detener"		
		#log "ERR" "Error al detener el demonio con pid $PID"    
	    fi

	    PID=$(getPid $1)

	    if [ "$PID" != "" ]; then
		echo "No se detuvo"
		#log "ERR" "No se pudo detener el demonio"    
		exit 1
	    fi
	    echo "Se detuvo RecibirOfertas"
	    #log "INFO" "Se detuvo el demonio"
	    exit 0
	fi

}

####################   POR CONSOLA SOLO ARRANCA EL DEMONIO  #########################

if [ $# != 1 ] ;then
	echo "Modo de detencion \"DetenerProceso.sh RecibirOfertas\""
	exit 1
fi

detener
###########################################################

#! /bin/bash

# Arranque de Scripts
# $1 script a correr
# $2 script que lo corrio (si no es por consola)

#########################  Procedimientos ##################################
source FuncionesVarias.sh

GRABITAC="$BINDIR/GrabarBitacora.sh"
comandoAInvocar=$1
comandoInvocador=$2

function verificarComandoInvocado(){
	if [ ! -f $BINDIR/$comandoAInvocar.sh ]; then
    		local mensajeError="El comando ingresado es Incorrecto"
		imprimirResultado "$mensajeError" "ERR"
		exit 1
	fi
}

function verificarAmbiente(){
	if [ $comandoAInvocar != "PrepararAmbiente" ];then
		ambienteInicializado
		if [ $? == 1 ];then
			local mensajeError="Ambiente no inicializado"
			imprimirResultado "$mensajeError" "ERR"
			exit 1
		fi
	fi
}

function verificarProcesoCorriendo(){
	PID=$(getPid $comandoAInvocar)
	if [ ! -z "$PID" ];then
		local mensaje="$comandoAInvocar ya esta corriendo con PID: $PID"
		imprimirResultado "$mensaje" "WAR"
		exit 1
	fi
}

# $1 Mensaje $2 Tipo Mensaje
function imprimirResultado(){
	#si no hay comandoInvocador es porque se corrio por consola
	if [ ! -z $comandoInvocador ];then
		msjLog "$1" "$2"
	fi
	echo "$2: $1"
}

function msjLog() {
	  local MENSAJE=$1
	  local TIPO=$2
	  # solo graba si se invoca por un comando que registre en su log
	  if [ $COMANDOGRABA = "true" ]; then
	    $GRABITAC "$BINDIR/$comandoInvocador.sh" "$MENSAJE" "$TIPO"
	  fi
}


#Si LanzarProceso.sh es invocado por un comando que graba en un archivo de log, registrar en el log del comando
function grabaEnLog() {
	if [ "$comandoInvocador" == "RecibirOfertas" ] || [ "$comandoInvocador" == "PrepararAmbiente" ] || [ "$comandoInvocador" == "ProcesarOfertas" ] || [ "$comandoInvocador" == "GenerarSorteo" ] || [ "$comandoInvocador" == "DeterminarGanadores" ] ; then
	  COMANDOGRABA="true"
	  MENSAJE="Se ha invocado al script LanzarProceso.sh para arrancar $comandoAInvocar."
	  msjLog "$MENSAJE" "INFO"
	fi
}

function arrancar(){

	verificarAmbiente
	verificarComandoInvocado
	grabaEnLog
	verificarProcesoCorriendo
	#para que RecibirOfertas corra como daemon
	if [ "${comandoAInvocar}" == "RecibirOfertas" ];then
		nohup $BINDIR/$comandoAInvocar.sh > /dev/null 2>&1 &
	else
		$BINDIR/$comandoAInvocar.sh &
	fi

	PID=$(getPid $comandoAInvocar)
	if [ ! -z $PID ];then
		mensaje="$comandoAInvocar corriendo bajo el no.: $PID. Para detenerlo ejecute DetenerProceso.sh $comandoAInvocar"
		tipo="INFO"
	else
		mensaje="Error al arrancar el comando $comandoAInvocar"
		tipo="ERR"
	fi

	imprimirResultado "${mensaje}" "${tipo}"
	if [ $tipo = "ERR" ];then
		exit 1
	else
		exit 0
	fi
}
####################   POR CONSOLA SOLO ARRANCA EL DEMONIO  #########################

if [ $# -lt 1 ];then
	echo "Modo de arranque incorrecto, por favor intente de la siguiente forma: \"LanzarProceso.sh RecibirOfertas\""
	exit 1
fi

if [ $# == 1 ] && [ "$comandoAInvocar" != "RecibirOfertas" ];then
	echo "Modo de arranque incorrecto, por favor intente de la siguiente forma: \"LanzarProceso.sh RecibirOfertas\""
	exit 1	
fi
arrancar

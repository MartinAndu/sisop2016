#! /bin/bash


source FuncionesVarias.sh
FILE="$LOGDIR/$1".log # Archivo log
STRING=$2  # String que se busca
GRABITAC="$BINDIR/GrabarBitacora.sh"


function verificarAmbiente(){
	ambienteInicializado 
	if [ $? == 1 ]; then
		local mensajeError="Ambiente no inicializado"
		echo "$mensajeError":"ERR"
		exit 1
	fi
}

verificarAmbiente

if [ $# -lt 2 ]; then
	MSJOUT="Ingreso menos de dos parametros"
	echo $MSJOUT
	"$GRABITAC" "$0" "${MSJOUT}" "ERR"
	exit 1
fi

if [ $# -gt 2 ]; then
	MSJOUT="Ingreso más de dos parámetros"
	echo $MSJOUT
	"$GRABITAC" "$0" "${MSJOUT}" "ERR"	
	exit 1
fi

if [ ! -f "${FILE}" ]; then
	MSJOUT="El archivo no existe"
	echo  $MSJOUT
	"$GRABITAC" "$0" "${MSJOUT}" "ERR"
	exit 1
fi


if [ $STRING == "-all" ]; then
	cat -n "$FILE"
else
	cat -n "$FILE" | grep "$STRING"
fi

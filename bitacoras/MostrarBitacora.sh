#! /bin/bash

FILE="$1".log # Archivo log
STRING=$2  # String que se busca
GRABITAC="$BINDIR/GrabarBitacora.sh"

if [ $# -lt 2 ]; then
	MSJOUT="Ingreso menos de dos parametros"
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


cat -n "$FILE" | grep "$STRING"





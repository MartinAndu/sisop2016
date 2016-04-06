#!/bin/bash

IFS='
'
TRUE=1
FALSE=0
function NovedadesPendientes() {
	echo "NovedadesPendientes..."
}

function Validar() {
	local validacionNombre=`echo $1 | grep ^[a-zA-Z0-9]*_[0-9]*.csv$`

	eval $validacionNombre
	local resultadoEvaluacion=$?

	if [ $resultadoEvaluacion -eq $FALSE ]; then
		return $FALSE

	local separacionNombre=`echo $1 | sed 's/.csv//g' | sed 's/_/\n/g'`



	return $TRUE
}

#verifico que haya archivos en ARRIDIR
GRUPO=`pwd`
ARRIDIR=$GRUPO
ARRIDIR=$ARRIDIR"/arribados"
MAEDIR=$GRUPO"/maestros"


if [ ! -d $ARRIDIR ]; then
	echo "arribados=$ARRIDIR"
	echo "La carpeta no existe. "
	exit
fi

cantidadArchivos=`ls -l $ARRIDIR | wc -l`
cantidadArchivos=`echo $cantidadArchivos - 1 | bc`

if [ $cantidadArchivos -eq $FALSE ] ; then
	# ir a novedades pendientes
	NovedadesPendientes
fi

for archivo in `ls -C $ARRIDIR`
do
	Validar $archivo
	valResultado=$?
	if [ $valResultado -eq $FALSE ]
	then
		#MoverArchivos($archivo)
		# escribir log
		echo 'NO'
	else
		#MoverArchivos($archivo) => OK
		#escribir log
		echo "OK"
	fi
done

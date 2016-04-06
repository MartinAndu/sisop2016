#!/bin/bash


IFS='
'
TRUE=1
FALSE=0

GRABITAC=$(pwd)"/grabarbitacora.sh"
MOVER=$(pwd)"/mover.sh"


function msjLog() {
  local MOUT=$1
  local TIPO=$2
  echo "${MOUT}"
  $GRABITAC "$0" "$MOUT" "$TIPO"
}

function NovedadesPendientes() {
	echo "NovedadesPendientes..."
}

function Validar() {
	local validacionNombre=`echo $1 | grep ^[a-zA-Z0-9]*_[0-9]*.csv$`

	eval $validacionNombre
	local resultadoEvaluacion=$?

	if [ $resultadoEvaluacion -eq $FALSE ]; then
		return $FALSE
	fi

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
		MSJ="NO"
  		msjLog "${MSJ}" "INFO"
		echo 'NO'
	else
		#MoverArchivos($archivo) => OK
		#escribir log
		MSJ="OK"
  		msjLog "${MSJ}" "INFO"
		echo "OK"
	fi
done

# TODO: Prueba para mover. Borrar esto dsp.
# Esto funciona, no los cree en el repositorio por un tema de prolijidad
$MOVER "$(pwd)/pruebita.txt" "$(pwd)/arribados" "${0}"

# TODO: Prueba para log. Borrar esto dsp.
MSJ="Prueba Log Sorteo 2016"
msjLog "${MSJ}" "INFO"
echo 'NO'
#!/bin/bash


IFS='
'
TRUE=0
FALSE=1

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
	local validacionNombre=$(echo $1 | grep ^[a-zA-Z0-9]*_[0-9]*.csv$)
	local resultadoEvaluacion=$?
	if [ $resultadoEvaluacion -eq $FALSE ]; then
		return $FALSE
	fi

	local separacionConcesionario=`echo $1 | sed 's-\([a-zA-Z0-9]*\)_\([0-9]*\).csv$-\1-g'`
	local separacionFecha=`echo $1 | sed 's-\([a-zA-Z0-9]*\)_\([0-9]*\).csv$-\2-g'`

	# verifico que el concesionario exista en el maestro de concesionarios
	local validacionConcesionario=$(cut -d, -f1 concesionarios.csv.xls | grep $separacionConcesionario)
	if [ $resultadoEvaluacion -eq $FALSE ]; then
		return $FALSE
	fi

	# PARTE DE VALIDACIONES DE FECHA
	# verifico que sea una fecha valida
	echo "empiezo a validar las fechas $separacionFecha"
	local validacionFecha=$(date -d "$separacionFecha" +%y/%m/%d)
	#eval $validacionFecha

	resultadoEvaluacion=$?
	echo "resultadoEvaluacion=$resultadoEvaluacion"
	if [ $resultadoEvaluacion -eq $FALSE ]; then
		# la fecha no es valida
		return $FALSE
	fi

	# necesito saber la fecha del ultimo acto de adjudicacion
	#TODO me quede aca
	local fechaUltimoActoAdjudicacion=$(cut FechasAdj.csv.xls -d';' -f1)
	local validacionFecha=$(date -d "$separacionFecha" +%s)
	local fechaActual=$(date +%s)
	local fechaMayor=0
	for fecha in $fechaUltimoActoAdjudicacion
	do
		echo "fecha antes sed=$fecha"
		fecha=`echo $fecha | sed 's-\([0-9]*\)/\([0-9]*\)/\([0-9]*\)$-\2/\1/\3-g'`
		echo "fecha despues sed=$fecha"
		fecha_=$(date -d "$fecha" +%s)
		if [ $fecha_ -ge $fechaMayor ] ; then
			fechaMayor=$fecha_
			echo "fechaMayor=$fechaMayor"
		fi
	done
	echo "validacionFecha=$validacionFecha"
	echo "fechaActual=$fechaActual"
	if [ $validacionFecha -le $fechaActual -a $validacionFecha -gt $fechaMayor ] ; then
		return $TRUE
	else
		return $FALSE
	fi
}

#verifico que haya archivos en ARRIDIR
GRUPO=`../`
ARRIDIR=$GRUPO
ARRIDIR=$ARRIDIR"/arribados"
MAEDIR=$GRUPO"/maestros"


if [ ! -d $ARRIDIR ]; then
	echo "arribados=$ARRIDIR"
	echo "La carpeta no existe. "
	exit
fi

cantidadArchivos=`ls -A $ARRIDIR | wc -l`
#cantidadArchivos=`echo $cantidadArchivos - 1 | bc`

if [ $cantidadArchivos -eq $FALSE ] ; then
	# ir a novedades pendientes
	NovedadesPendientes
fi

for archivo in `ls -A $ARRIDIR`
do
	echo "archivo=$archivo"
	Validar $archivo
	valResultado=$?
	if [ $valResultado -eq $FALSE ]
	then
		#MoverArchivos($archivo)
		# escribir log
		#MSJ="NO"
  		#msjLog "${MSJ}" "INFO"
		echo 'NO'
	else
		#MoverArchivos($archivo) => OK
		#escribir log
		#MSJ="OK"
  		#msjLog "${MSJ}" "INFO"
		echo "OK"
	fi
done

# TODO: Prueba para mover. Borrar esto dsp.
# Esto funciona, no los cree en el repositorio por un tema de prolijidad#
#$MOVER "$(pwd)/pruebita.txt" "$(pwd)/arribados" "${0}"

# TODO: Prueba para log. Borrar esto dsp.
#MSJ="Prueba Log Sorteo 2016"
#msjLog "${MSJ}" "INFO"
#echo 'NO'

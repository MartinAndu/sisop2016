#!/bin/bash

IFS='
'
TRUE=0
FALSE=1
CICLO=1
GRABITAC=$"$BINDIR/GrabarBitacora.sh"
MOVER=$"$BINDIR/MoverArchivo.sh"
MENSAJEERROR=""

function msjLog() {
  local MOUT=$1
  local TIPO=$2
  echo "${MOUT}"
  $GRABITAC "$0" "$MOUT" "$TIPO"
}

function NovedadesPendientes() {
	cantidadArchivos=`ls -A $OKDIR | wc -l`
	if [ $cantidadArchivos -ge 0 ] ; then
		return
	fi

	#llamo a ProcesarOfertas siempre y cuando no este corriendo
	procesos=$(ps -fea | grep ProcesarOfertas | wc -l)
	if [ $procesos -eq 2 ]; then
		#significa que esta corriendo
		mensaje="Invocacion de ProcesarOfertas pospuesta para el siguiente ciclo."
		msjLog "$mensaje" "INFO"
	else
		#llamo a ProcesarOfertas
		#TODO falta ponerle el pid en el mensaje y lanzar proceso
		mensaje="ProcesarOfertas corriendo bajo el no.: "
		msjLog $mensaje "INFO"
	fi
}

function Validar() {
	local validacionNombre=$(echo $1 | grep ^[a-zA-Z0-9]*_[0-9]*.csv$)
	local resultadoEvaluacion=$?
	if [ $resultadoEvaluacion -eq $FALSE ]; then
		MENSAJEERROR="$1 no es un nombre de archivo valido."
		return $FALSE
	fi

	local separacionConcesionario=`echo $1 | sed 's-\([a-zA-Z0-9_]*\)_\([0-9]*\).csv$-\1-g'`
	local separacionFecha=`echo $1 | sed 's-\([a-zA-Z0-9_]*\)_\([0-9]*\).csv$-\2-g'`

	# verifico que el concesionario exista en el maestro de concesionarios
	local validacionConcesionario=$(cut -d, -f1 "$MAEDIR/concesionarios.csv" | grep $separacionConcesionario)
	if [ $resultadoEvaluacion -eq $FALSE ]; then
		MENSAJEERROR="El concesionario $separacionConcesionario no existe en el archivo maestro."
		return $FALSE
	fi

	# PARTE DE VALIDACIONES DE FECHA
	# verifico que sea una fecha valida
	local validacionFecha=$(date -d "$separacionFecha" +%y/%m/%d)

	resultadoEvaluacion=$?
	if [ $resultadoEvaluacion -eq $FALSE ]; then
		MENSAJEERROR="La fecha $separacionFecha no tiene un nombre valido."
		return $FALSE
	fi

	# llamo a UltimaFechaAdj para obtener la ultima fecha de adjudicacion
	local fechaUltimoActoAdjudicacion=$($BINDIR/UltimaFechaAdj.sh)
	local validacionFecha=$(date -d "$separacionFecha" +%s)
	local fechaActual=$(date +%s)

	if [ $validacionFecha -le $fechaActual ] ; then
		if [ $validacionFecha -gt $fechaUltimoActoAdjudicacion ] ; then
			MENSAJEERROR=""
			return $TRUE
		else
			MENSAJEERROR="La fecha `date -d"@$validacionFecha" +%d/%m/%Y` es menor que la fecha del ultimo acto de adjudicacion (`date -d"@$fechaUltimoActoAdjudicacion" +%d/%m/%Y`)."
			return $FALSE
		fi
	else
		MENSAJEERROR="La fecha `date -d"@$validacionFecha" +%d/%m/%Y` es mayor que la fecha del dia actual.(`date  +%d/%m/%Y`)"
		return $FALSE
	fi
}

#verifico que haya archivos en ARRIDIR
## TODO: cambiar esto cuando este lista la parte de las variables globales
#GRUPO=`../`
#ARRIDIR=$GRUPO
ARRIDIR="../arribados"
MAEDIR="../maestros"
SLEEPTIME=10

#Validacion del entorno de ejecucion

if [ ! -d $ARRIDIR ]; then
	msjLog "Error Critico: La carpeta de archivos arribados no exsite o no tiene permiso de lectura." "ERR"
	exit 1
fi

if [ ! -d $NOKDIR ]; then
	msjLog "Error Critico: La carpeta de archivos rechazados no exsite o no tiene permiso de lectura." "ERR"
	exit 1
fi

if [ ! -d $OKDIR ]; then
	msjLog "Error Critico: La carpeta de archivos aceptados no exsite o no tiene permiso de lectura." "ERR"
	exit 1
fi

if [ ! -r "$MAEDIR/concesionarios.csv" ]; then
	msjLog "Error Critico: No se puede acceder para lectura el archivo concesionarios.csv necesario para la ejecucion del modulo." "ERR"
	exit 1
fi

if [ ! -r "$MAEDIR/FechasAdj.csv" ]; then
	msjLog "Error Critico: No se puede acceder para lectura el archivo FechasAdj.csv necesario para le ejecucion del modulo." "ERR"
	exit 1
fi

if [ ! -x "$BINDIR/MoverArchivo.sh" ]; then
	msjLog "Error critico: El script MoverArchivo.sh no tiene permisos de ejecucion" "ERR"
	exit 1
fi

if [ ! -x "$BINDIR/GrabarBitacora.sh" ]; then
	msjLog "Error critico: El script GrabarBitacora.sh no tiene permisos de ejecucion" "ERR"
	exit 1
fi


function main()
{
	# me fijo cuantos archivos hay en ARRIDIR
	msjLog "RecibirOfertas ciclo nro. $CICLO" "INFO"
	cantidadArchivos=`ls -A $ARRIDIR | wc -l`

	# si no hay archivos, llamo a novedades pendientes
	if [ $cantidadArchivos -eq 0 ] ; then
		# ir a novedades pendientes
		NovedadesPendientes
	fi

	for archivo in `ls -A $ARRIDIR`
	do
		Validar $archivo
		valResultado=$?
		if [ $valResultado -eq $FALSE ]
		then
			#MoverArchivos($archivo)
			msjLog  "$MENSAJEERROR" "ERR"
			$MOVER "$ARRIDIR/$archivo" "$NOKDIR" $0
		else
			$MOVER "$ARRIDIR/$archivo" "$OKDIR/" $0
			#MoverArchivos($archivo) => OK
			#escribir log
			#MSJ="OK"
  			#msjLog "${MSJ}" "INFO"
			echo "OK"
		fi
	done

	CICLO=`echo $CICLO + 1 | bc`
}

#NoTerminaRecibir=1
while [ 1 ]; do
	main
	sleep $SLEEPTIME
done

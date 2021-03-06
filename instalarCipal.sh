	#!/bin/bash

GRUPO=~/grupo02
CONFG="$GRUPO/config/CIPAL.cnf"
GRABITAC="$GRUPO/binarios/GrabarBitacora.sh"


escribirConfig () {
	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}	

	#GRUPO
	echo "GRUPO=$GRUPO=$WHO=$WHEN" >> "$CONFG"
	#CONFDIR
	echo "CONFDIR=$GRUPO/$CONFDIR=$WHO=$WHEN" >> "$CONFG"
	#BINDIR
	echo "BINDIR=$GRUPO/$BINDIR=$WHO=$WHEN" >> "$CONFG"
	#MAEDIR
	echo "MAEDIR=$GRUPO/$MAEDIR=$WHO=$WHEN" >> "$CONFG"
	#ARRIDIR
	echo "ARRIDIR=$GRUPO/$ARRIDIR=$WHO=$WHEN" >> "$CONFG"
	#OKDIR
	echo "OKDIR=$GRUPO/$OKDIR=$WHO=$WHEN" >> "$CONFG"
	#PROCDIR
	echo "PROCDIR=$GRUPO/$PROCDIR=$WHO=$WHEN" >> "$CONFG"
	#INFODIR
	echo "INFODIR=$GRUPO/$INFODIR=$WHO=$WHEN" >> "$CONFG"
	#LOGDIR
	echo "LOGDIR=$GRUPO/$LOGDIR=$WHO=$WHEN" >> "$CONFG"
	#NOKDIR
	echo "NOKDIR=$GRUPO/$NOKDIR=$WHO=$WHEN" >> "$CONFG"
	#LOGSIZE
	echo "LOGSIZE=$LOGSIZE=$WHO=$WHEN" >> "$CONFG"

	#SLEEPTIME
	echo "SLEEPTIME=$SLEEPTIME=$WHO=$WHEN" >> "$CONFG"
	#LOCKDIR Establece el directorio raiz grupo02
	echo "LOCKDIR=$GRUPO=$WHO=$WHEN" >> "$CONFG"

	echo "Archivo de configuracion creado"
}

moverArchivos (){
	totalArchivos=`ls "$(pwd)/binarios"`

	echo "Instalando programas"


	for archivoEjecutables in ${totalArchivos[*]}
	do
		cp "$(pwd)/binarios/$archivoEjecutables" "$GRUPO/$BINDIR"
		cp "$(pwd)/binarios/$archivoEjecutables" "$GRUPO/$BIN"
	done

	echo "Copiando archivos Maestros"

	totalArchivos=`ls "$(pwd)/maestros"`

	for archivoMaestros in ${totalArchivos[*]}
	do
		cp "$(pwd)/maestros/$archivoMaestros" "$GRUPO/$MAEDIR"
		cp "$(pwd)/maestros/$archivoMaestros" "$GRUPO/$MAE"

	done

}


definirDirectoriosyParametros (){
	echo "Creando archivos de directorio.."	

	BINDIR="binarios"
	MAEDIR="maestros"
	ARRIDIR="arribados"
	OKDIR="aceptados"
	PROCDIR="procesados"
	INFODIR="informes"
	LOGDIR="bitacoras"
	NOKDIR="rechazados"
	CONFDIR="config"
	BIN="BIN"
	MAE="MAE"
	SLEEPTIME=10
	LOGSIZE=10

}

instalacion (){
	# Define nombre de directorios.
	definirDirectoriosyParametros

  	echo -e "El sistema sera instalado en: " '\n' $GRUPO'\n''\n'
	variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR}/procesadas ${PROCDIR}/rechazadas ${PROCDIR}/sorteos ${PROCDIR}/validas ${INFODIR} ${LOGDIR} ${NOKDIR} ${CONFDIR} ${CONFDIR} ${MAE} ${BIN})
	echo "Creando Estructuras de directorio.." 

	for index in ${variables[*]}
	do
		echo "Creando $index"
		mkdir -p "$GRUPO/$index"
	done


	# Escribe el archivo de configuracion si no existe.

	if [ ! -f "$CONFG" ]; then
 		escribirConfig
 	fi

	#Mueve los ejecutables y los archivos maestros
	moverArchivos

	echo "Fin instalacion"
}


# instalacion
instalacion

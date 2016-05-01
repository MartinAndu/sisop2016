#!/bin/bash

GRUPO=~/grupo02
CONFG="$GRUPO/$CONFDIR/CIPAL.cnf"
GRABITAC="$GRUPO/binarios/GrabarBitacora.sh"


escribirConfig () {
	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}

	#GRUPO
	echo "GRUPO=$GRUPO=$WHO=$WHEN" >> $CONFG
	#CONFDIR
	echo "CONFDIR=$GRUPO/$CONFDIR=$WHO=$WHEN" >> $CONFG
	#BINDIR
	echo "BINDIR=$GRUPO/$BINDIR=$WHO=$WHEN" >> $CONFG
	#MAEDIR
	echo "MAEDIR=$GRUPO/$MAEDIR=$WHO=$WHEN" >> $CONFG
	#ARRIDIR
	echo "ARRIDIR=$GRUPO/$ARRIDIR=$WHO=$WHEN" >> $CONFG
	#OKDIR
	echo "OKDIR=$GRUPO/$OKDIR=$WHO=$WHEN" >> $CONFG
	#PROCDIR
	echo "PROCDIR=$GRUPO/$PROCDIR=$WHO=$WHEN" >> $CONFG
	#INFODIR
	echo "INFODIR=$GRUPO/$INFODIR=$WHO=$WHEN" >> $CONFG
	#LOGDIR
	echo "LOGDIR=$GRUPO/$LOGDIR=$WHO=$WHEN" >> $CONFG
	#NOKDIR
	echo "NOKDIR=$GRUPO/$NOKDIR=$WHO=$WHEN" >> $CONFG
	#LOGSIZE
	echo "LOGSIZE=$GRUPO/$LOGSIZE=$WHO=$WHEN" >> $CONFG
	#SLEEPTIME
	echo "SLEEPTIME=$GRUPO/$SLEEPTIME=$WHO=$WHEN" >> $CONFG

	echo "Archivo de configuracion creado"
}

moverArchivos (){
	totalArchivos=`ls $(pwd)/binarios`

	echo "Instalando programas"


	for archivoEjecutables in ${totalArchivos[*]}
	do
		cp $(pwd)/binarios/$archivoEjecutables $GRUPO/$BINDIR
	done 

	echo "Copiando archivos Maestros"

	totalArchivos=`ls $(pwd)/maestros`

	for archivoMaestros in ${totalArchivos[*]}
	do
		cp $(pwd)/maestros/$archivoMaestros $GRUPO/$MAEDIR
	done 

}


definirDirectorio (){
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
} 

instalacion (){

	# Define nombre de directorios.
	definirDirectorio
	# Escribe el archivo de configuracion.
 	escribirConfig


  	echo -e "El sistema sera instalado en: " '\n' $GRUPO'\n''\n'
	variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR}/proc ${INFODIR} ${LOGDIR} ${NOKDIR} ${CONFDIR})
	echo "Creando Estructuras de directorio.." 

	for index in ${variables[*]}
	do
		echo "Creando $index"
		mkdir -p $GRUPO/$index
	done

	#Mueve los ejecutables y los archivos maestros
	moverArchivos

	echo "Fin instalacion"
}


# instalacion
instalacion

#!/bin/bash

GRUPO=~/grupo02;
CONFG=$(pwd)"/CONFDIR/CIPAL.cnf"
GRABITAC=$(pwd)"/binarios/GrabarBitacora.sh"



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


	local msj="Archivo de configuracion creado"
	$GRABITAC "$0" "${msj}" "INFO"

}

moverArchivos (){
	totalArchivos=`ls $(pwd)/BIN`

	echo "Instalando programas"

	for archivoEjecutables in ${totalArchivos[*]}
	do
		cp $(pwd)/BIN/$archivoEjecutables $GRUPO/$BINDIR
	done 

	echo "Copiando archivos Maestros"

	totalArchivos=`ls $(pwd)/MAE`

	for archivoMaestros in ${totalArchivos[*]}
	do
		cp $(pwd)/MAE/$archivoEjecutables $GRUPO/$MAEDIR
	done 

}

instalacion (){

	#Escribe el archivo de configuracion
 	escribirConfig


	GRUPO=$(grep '^GRUPO' $CONFG | cut -d '=' -f 2)
 	BINDIR=$(grep '^BINDIR' $CONFG | cut -d '=' -f 2)
  	MAEDIR=$(grep '^MAEDIR' $CONFG | cut -d '=' -f 2)
  	ARRIDIR=$(grep '^ARRIDIR' $CONFG | cut -d '=' -f 2)
  	OKDIR=$(grep '^OKDIR' $CONFG | cut -d '=' -f 2)
  	PROCDIR=$(grep '^PROCDIR' $CONFG | cut -d '=' -f 2)
  	INFODIR=$(grep '^INFODIR' $CONFG | cut -d '=' -f 2)
  	LOGDIR=$(grep '^LOGDIR' $CONFG | cut -d '=' -f 2)
  	NOKDIR=$(grep '^NOKDIR' $CONFG | cut -d '=' -f 2)
  	LOGSIZE=$(grep '^LOGSIZE' $CONFG | cut -d '=' -f 2)
  	SLEEPTIME=$(grep '^SLEEPTIME' $CONFG | cut -d '=' -f 2)



	variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR}/proc ${INFODIR} ${LOGDIR} ${NOKDIR})
	echo "Creando Estructuras de directorio" 

	for index in ${variables[*]}
	do
		#echo "Creando $index"
		mkdir -p $GRUPO/$index
	done

	#Mueve los ejecutables y los archivos maestros
	#moverArchivos

	echo "Fin instalacion"
}


instalacion


#!/bin/bash


escribirConfig () {
	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}

	#GRUPO
	echo "GRUPO=$GRUPO=$WHO=$WHEN" >> $AFRACONFIG
	#CONFDIR
	echo "CONFDIR=$GRUPO/$CONFDIR=$WHO=$WHEN" >> $AFRACONFIG
	#BINDIR
	echo "BINDIR=$GRUPO/$BINDIR=$WHO=$WHEN" >> $AFRACONFIG
	#MAEDIR
	echo "MAEDIR=$GRUPO/$MAEDIR=$WHO=$WHEN" >> $AFRACONFIG
	#NOVEDIR
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
	variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR} ${INFODIR} ${LOGDIR} ${NOKDIR})
	echo "Creando Estructuras de directorio"
	for index in ${variables[*]}
	do
		echo "Creando $index"
		mkdir -p $GRUPO/$index
	done

	#Escribe el archivo de configuracion
 	escribirConfig

	#Mueve los ejecutables y los archivos maestros
	moverArchivos

	echo "Fin instalacion"
}


instalacion


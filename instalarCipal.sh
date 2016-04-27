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

instalacion (){
	variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR} ${INFODIR} ${LOGDIR} ${NOKDIR})
}



verificarExistenciaDeDirectoriosYArchivos
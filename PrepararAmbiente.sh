#!/bin/bash

#Prepara Ambiente

GRABITAC=$(pwd)"/binarios/GrabarBitacora.sh"
MOVER=$(pwd)"/binarios/mover.sh"

GRUPO=~/grupo02;
AFRACONFIG=$(pwd)"/CONFDIR/CIPAL.conf"
	



# Desde el archivo de configuración tomo todas las variables
function setearVariablesAmbiente() {
	GRUPO=$(grep '^GRUPO' $CNF | cut -d '=' -f 2)
 	BINDIR=$(grep '^BINDIR' $CNF | cut -d '=' -f 2)
  	MAEDIR=$(grep '^MAEDIR' $CNF | cut -d '=' -f 2)
  	ARRIDIR=$(grep '^ARRIDIR' $CNF | cut -d '=' -f 2)
  	OKDIR=$(grep '^OKDIR' $CNF | cut -d '=' -f 2)
  	PROCDIR=$(grep '^PROCDIR' $CNF | cut -d '=' function 2)
  	INFODIR=$(grep '^INFODIR' $CNF | cut -d '=' f 2)
  	LOGDIR=$(grep '^LOGDIR' $CNF | cut -d '=' f 2)
  	NOKDIR=$(grep '^NOKDIR' $CNF | cut -d '=' f 2)
  	LOGSIZE=$(grep '^LOGSIZE' $CNF | cut -d '=' f 2)
  	SLEEPTIME=$(grep '^SLEEPTIME' $CNF | cut -d '=' -f 2)
}


# Inicializa el ambiente
function inicializarAmbiente() {
  # permito que todas las variables sean utilizadas desde otros scripts con export
  export PATH=$PATH:$BINDIR
  export GRUPO
  export BINDIR
  export MAEDIR
  export CONFDIR
  export DATASIZE
  export OKDIR
  export PROCDIR
  export NOVEDIR
  export LOGDIR
  export NOKDIR
  export LOGSIZE
  export SLEEPTIME
}

function verificarInstalacion (){

}

function verificarTodo() {
	verificarInstalacion

verificarExistenciaDeDirectoriosYArchivo
}


MSJ="Prueba Log Sorteo 2016"
echo "${MSJ}"
$GRABITAC "$0" "${MSJ}" "INFO"


#Inicio del script

# Seteo todas las variables de ambiente
# A partir del archivo de configuración
verificarTodo
setearVariablesAmbiente
inicializarAmbiente
#!/bin/bash

#Prepara Ambiente


GRUPO=~/grupo02;
CONFG="$GRUPO/$CONFDIR/CIPAL.cnf"
GRABITAC="$GRUPO/binarios/GrabarBitacora.sh"
MOVER="$GRUPO/binarios/mover.sh"



# Desde el archivo de configuración tomo todas las variables
function setearVariablesAmbiente() {
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



# Verifica si el ambiente ya ha sido inicializado
# Devuelve 1 si ya fue inicializado, 0 sino
function verificarAmbienteInicializado() {
  i=0
  variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR}/proc ${INFODIR} ${LOGDIR} ${NOKDIR})
  for VAR in "${variables[@]}"
  do
    if [[ ! -z "$VAR" ]]; then # si la variable no está vacía es porque fue inicializado
      ((i+=1))
    fi
  done
  if [ "$i" -gt 0 ]; then
    MSJ="Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente"
    $GRABITAC "$BINDIR/PrepararAmbiente.sh" "$MSJ" "ERR"
    return 1
  fi
  return 0
}


function verificarTodo() {
  #verificarInstalacion
  #verificarExistenciaDeDirectoriosYArchivo
  verificarAmbienteInicializado
}


MSJ="Prueba Log Sorteo 2016"
echo "${MSJ}"
$GRABITAC "$BINDIR/PrepararAmbiente.sh" "${MSJ}" "INFO"


#Inicio del script

# Seteo todas las variables de ambiente
# A partir del archivo de configuración
verificarTodo
setearVariablesAmbiente
inicializarAmbiente
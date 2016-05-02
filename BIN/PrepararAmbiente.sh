#!/bin/bash

#Prepara Ambiente
CONFDIR="config"
CONFG="$GRUPO/$CONFDIR/CIPAL.cnf"
GRABITAC="$GRUPO/binarios/GrabarBitacora.sh"
MOVER="$GRUPO/binarios/mover.sh"



# Desde el archivo de configuración tomo todas las variables
function setearVariablesAmbiente() {
  	GRUPO=$(grep '^GRUPO' "$CONFG" | cut -d '=' -f 2)
    BINDIR=$(grep '^BINDIR' "$CONFG" | cut -d '=' -f 2)
    MAEDIR=$(grep '^MAEDIR' "$CONFG" | cut -d '=' -f 2)
    ARRIDIR=$(grep '^ARRIDIR' "$CONFG" | cut -d '=' -f 2)
    OKDIR=$(grep '^OKDIR' "$CONFG" | cut -d '=' -f 2)
    PROCDIR=$(grep '^PROCDIR' "$CONFG" | cut -d '=' -f 2)
    INFODIR=$(grep '^INFODIR' "$CONFG" | cut -d '=' -f 2)
    LOGDIR=$(grep '^LOGDIR' "$CONFG" | cut -d '=' -f 2)
    NOKDIR=$(grep '^NOKDIR' "$CONFG" | cut -d '=' -f 2)
    LOGSIZE=$(grep '^LOGSIZE' "$CONFG" | cut -d '=' -f 2)
    SLEEPTIME=$(grep '^SLEEPTIME' "$CONFG" | cut -d '=' -f 2)
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
  export LOGDI 
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
    "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "$MSJ" "ERR"
    return 1
  fi
  return 0
}

function verificarArchivos() {
  completo=0
  faltantes=()
  for ARCH IN "${archivos}"
  do

    # ¿Existe el archivo?
    if [ ! -f $ARCH ]; then
      completo=1
      faltantes+=("$ARCH")
      echo "Falta el archivo $ARCH"
    fi
  done

  for SCRIPT IN "${scripts}"
  do

    # ¿Existe el script?
    if [ ! -f $SCRIPT ]; then
      faltantes+=("$SCRIPT")
      echo "Falta el script $SCRIPT"
    fi

  done

  if [ completo = 0]; then
    return 1
  fi
  return 0

}

function verificarInstalacion() {
  CONS="$MAEDIR/concesionarios.csv"
  FECHADJ="$MAEDIR/FechasAdj.csv"
  GRU="$MAEDIR/grupos.csv"
  TEMA="$MAEDIR/temaL_padron.csv"

  PERL="determinarGanadores.pl"
  SORTEO="GenerarSorteo.sh"
  BIT="GrabarBitacora.sh"
  MOV="MoverArchivo.sh"
  AMB="PrepararAmbiente.sh"
  OFERTA="ProcesarOfertas.sh"
  ADJ="ProximaFechaAdj.sh"
  OFERTA="RecibirOfertas.sh"
  ULTIMA="UltimaFechaAdj.sh"


  archivos=("$CONS" "$FECHADJ" "$GRU" "$TEMA")
  scripts=("$PERL" "$SORTEO" "$BIT" "$MOV" "$AMB" "$OFERTA" "$ADJ" "$OFERTA" "$ULTIMA")
  
  verificarArchivos
}

function verificarPermisos() {
  for ARCH in "${archivos[@]}"
  do
    chmod +x "$ARCH"
    if [ "$?" = -1 ]; then
      msj="El archivo \"${ARCH}\" no tiene los permisos necesarios"
      GRABITAC "$BINDIR/PrepararAmbiente.sh" "$msj" "ERR"
    fi
  done

  for SCRIPT in "${scripts[@]}"
  do
    chmod +x "$SCRIPT"
    if [ "$?" = -1 ]; then
      msj="El archivo \"${SCRIPT}\" no tiene los permisos necesarios"
      GRABITAC "$BINDIR/PrepararAmbiente.sh" "$msj" "ERR"
    fi
  done

}

function repararInstalacion(){


instalarFaltantes () {
  for I in ${faltantesDir[*]}
  do
    mkdir $I;
  done

  posicionActual=`pwd`
  
  for I2 in ${faltantesBin[*]}
  do
    cp $posicionActual/BIN/$I2 $BINDIR  
  done

  posicionActual=`pwd`

  for I3 in ${faltantesMae[*]}
  do
    cp $posicionActual/MAE/$I3 $MAEDIR  
  done
}

}

#Inicio del script

# Seteo todas las variables de ambiente
# A partir del archivo de configuración
verificarInstalacion
instCompleta=$?
if [ instCompleta = 1 ]; then
  instalarFaltantes
  verificarInstalacion
  instCompleta=$?
  if [ instCompleta = 1 ]; then
    echo "La instalación no está completa, existen los siguientes archivos faltantes $(printf '%s\n' "${faltantes[@]}")" 
    echo "Se deberá volver a realizar la instalación"
    return 1
  fi
fi

# Verifico permisos
verificarPermisos
permisos=$?
if [ permisos = 1 ]; then
  echo "Los permisos estan mal asignados"
  return 1
fi 


# Verifico si las variables estan seteadas
verificarAmbienteInicializado

setearVariablesAmbiente
inicializarAmbiente

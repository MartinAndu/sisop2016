#!/bin/bash

#Prepara Ambiente
CONFDIR=~/grupo02/config
CONFG=$CONFDIR/CIPAL.cnf
GRABITAC="GrabarBitacora.sh"
MOVER="MoverArchivo.sh"
LANZAR="LanzarProceso.sh"

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
    LOCKDIR=$(grep '^LOCKDIR' "$CONFG" | cut -d '=' -f 2)
}


# Inicializa el ambiente
function inicializarAmbiente() {
  # permito que todas las variables sean utilizadas desde otros scripts con export
  export PATH=$PATH:$BINDIR
  export GRUPO
  export ARRIDIR
  export BINDIR
  export MAEDIR
  export CONFDIR
  export DATASIZE
  export OKDIR
  export INFODIR
  export PROCDIR
  export LOGDIR
  export NOKDIR
  export LOGSIZE
  export LOCKDIR
  export SLEEPTIME
  export CONFDIR
}



# Verifica si el ambiente ya ha sido inicializado
# Devuelve 1 si ya fue inicializado, 0 sino
function verificarAmbienteInicializado() {
  i=0 
  variables=(${BINDIR} ${MAEDIR} ${ARRIDIR} ${OKDIR} ${PROCDIR} ${INFODIR} ${LOGDIR} ${NOKDIR})
  for VAR in "${variables[@]}"
  do
    if [[ ! -z "$VAR" ]]; then # si la variable no está vacía es porque fue inicializado
      ((i+=1))
    fi
  done
  if [ "$i" -gt 0 ]; then # Ambiente ya inicializado
    return 1
  fi
  return 0
}



function verificarInstalacion() {

  # Scripts y maestros a verificar
  CONS="$MAEDIR/concesionarios.csv"
  FECHADJ="$MAEDIR/FechasAdj.csv"
  GRU="$MAEDIR/Grupos.csv"
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
  LANZ="LanzarProceso.sh"


  archivos=("$CONS" "$FECHADJ" "$GRU" "$TEMA")
  scripts=("$PERL" "$SORTEO" "$BIT" "$MOV" "$AMB" "$OFERTA" "$ADJ" "$OFERTA" "$ULTIMA" "$LANZ")
  
  verificarArchivos
}

function verificarArchivos() {
  completo=0
  faltantesMAE=()
  faltantesBIN=()
  for ARCH in "${archivos}"
  do
    # ¿Existe el archivo?
    if [ ! -f "$ARCH" ]; then
      completo=1
      faltantesMAE+=("$ARCH")
      echo "Falta el archivo $ARCH"
    fi
  done

  for SCRIPT in "${scripts}"
  do

    # ¿Existe el script?
    if [ ! -f "$SCRIPT" ]; then
      completo=1
      faltantesBIN+=("$SCRIPT")
      echo "Falta el script $SCRIPT"
    fi

  done

  if [ completo = 1 ]; then # Si el archivo esta incompleto
    return 1
  fi
  return 0

}

function verificarPermisos() {
  permisos=0
  for ARCH in "${archivos[@]}"
  do
    chmod +r "$ARCH"
    if [ "$?" = -1 ]; then
      permisos=1
      msj="El archivo \"${ARCH}\" no tiene los permisos necesarios"
      $GRABITAC "$BINDIR/PrepararAmbiente.sh" "$msj" "ERR"
    fi
  done

  for SCRIPT in "${scripts[@]}"
  do
    chmod +x "$SCRIPT"
    if [ "$?" = -1 ]; then
      permisos=1
      msj="El archivo \"${SCRIPT}\" no tiene los permisos necesarios"
      $GRABITAC "$BINDIR/PrepararAmbiente.sh" "$msj" "ERR"
    fi
  done

  if [ permisos = 1 ]; then
    return 1
  fi
  return 0
}

function repararInstalacion(){
  # Repara instalacion

  posicionActual=`pwd`
  
  for I2 in ${faltantesBIN[*]}
  do
    cp $posicionActual/BIN/$I2 $BINDIR  
  done

  posicionActual=`pwd`

  for I3 in ${faltantesMAE[*]}
  do
    cp $posicionActual/MAE/$I3 $MAEDIR  
  done

}

# Muestra las variables de entorno y su contenido
function mostrarYGrabar() {


  variables=("$BINDIR" "$MAEDIR" "$ARRIDIR" "$OKDIR" "$PROCDIR" "$NOKDIR" "$LOGDIR" "$RECHDIR")
  mensajes=("Ejecutables" "Maestros y Tablas" "Recepción de archivos de novedades" "Archivos aceptados" "Archivos de ofertas procesadas"  "Archivos de Log" "Archivos de ofertas rechazadas")
  i=0
  for VAR in "${variables[@]}"
  do
    MSJ="Directorio de ""${mensajes[${i}]}":" $VAR"
    echo $MSJ
    "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "$MSJ" "INFO"
    # listar archivos si es BINDIR, MAEDIR, LOGDIR
    if [ "$VAR" = "$BINDIR" ] || [ "$VAR" = "$MAEDIR" ] || [ "$VAR" = "$LOGDIR" ] ; then
      LIST=$(ls "$VAR")
      "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "$LIST" "INFO"
    fi
    ((i+=1))
  done  
  "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "Estado del Sistema: INICIALIZADO" "INFO"
}

function deseaLanzar() {
  echo "¿Desea efectuar la activación de RECIBIROFERTAS? (Si - No)"
  read respuesta
  respuesta=${respuesta,,} # lo paso a lowercase
  case $respuesta in
    "no")
        echo "Modo de uso de comando ARRANCAR para iniciar RECIBIROFERTAS: LanzarProceso.sh RecibirOfertas" 
      ;;
    "si")
        $LANZAR RecibirOfertas PrepararAmbiente
      ;;
    *)
      echo "La respuesta debe ser \"Si\" o \"No\""
      deseaLanzar 
      ;;
  esac
}

#Inicio del script

# Seteo todas las variables de ambiente
# A partir del archivo de configuración
# Verifico si las variables estan seteadas

verificarAmbienteInicializado
ambienteIni=$?
if [ $ambienteIni == 1 ]; then
  MSJ="Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente"
  echo $MSJ
  "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "$MSJ" "ERR"
  return 1
fi
setearVariablesAmbiente

verificarInstalacion
instCompleta=$?
if [ $instCompleta == 1 ]; then
  echo "La instalación no está completa, existen los siguientes archivos faltantes $(printf '%s\n' "${faltantes[@]}")" 
  echo "Se deberá volver a realizar la instalación"
  return 1
fi

# Verifico permisos
verificarPermisos
permisos=$?
if [ $permisos == 1 ]; then
  echo "Los permisos estan mal asignados"
  return 1
fi 

inicializarAmbiente

mostrarYGrabar
deseaLanzar


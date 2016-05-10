#!/bin/bash


#Prepara Ambiente
CONFDIR=~/grupo02/config
CONFG=$CONFDIR/CIPAL.cnf
GRABITAC=~/grupo02/binarios/GrabarBitacora.sh
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
  # Mando la ruta directamente asi porque ejecutando con . ./PrepararAmbiente.sh, el $0 devuelve
  # el comando "bash"
  ambienteInicializado ~/grupo02/PrepararAmbiente.sh
}



function verificarInstalacion() {

  # Scripts y maestros a verificar
  CONS="concesionarios.csv"
  FECHADJ="FechasAdj.csv"
  GRU="Grupos.csv"
  TEMA="temaL_padron.csv"

  MOST="MostrarBitacora.sh"
  PERL="DeterminarGanadores.pl"
  SORTEO="GenerarSorteo.sh"
  BIT="GrabarBitacora.sh"
  MOV="MoverArchivo.sh"
  PROC="ProcesarOfertas.sh"
  ADJ="ProximaFechaAdj.sh"
  OFERTA="RecibirOfertas.sh"
  ULTIMA="UltimaFechaAdj.sh"
  LANZ="LanzarProceso.sh"
  DET="DetenerProceso.sh"
  PROX="ProximaFechaAdj.sh"
  VARIAS="FuncionesVarias.sh"

  archivos=("$CONS" "$FECHADJ" "$GRU" "$TEMA")
  scripts=("$MOV" "$PERL" "$SORTEO" "$BIT" "$MOST" "$OFERTA" "$ADJ" "$PROC" "$ULTIMA" "$LANZ" "$DET" "$PROX" "$VARIAS")
  
  verificarArchivos
}

function verificarArchivos() {
  incompleto=0
  faltantesMAE=()
  faltantesBIN=()
  rutamaestro=~/grupo02/maestros
  rutabinario=~/grupo02/binarios



  faltantesCarpetas=("$BINDIR" "$MAEDIR" "$ARRDIR" "$OKDIR" "$PROCDIR" "$PROCDIR/procesadas" "$PROCDIR/rechazadas" "$PROCDIR/sorteos" "$INFODIR" "$NOKDIR" "$CONFDIR" )

  for I in ${faltantesCarpetas[*]}
  do
    if [ ! -d "$I" ]; then
      incompleto=1
      faltantesCarpetas+=("$I")
      echo "Falta la carpeta $I"
    fi
  done

  for ARCH in ${archivos[*]}
  do
    # ¿Existe el archivo?
    if [ ! -f "$rutamaestro/$ARCH" ]; then
      incompleto=1
      faltantesMAE+=("$ARCH")
      echo "Falta el archivo $ARCH"
    fi
  done

  for SCRIPT in ${scripts[*]}
  do

    # ¿Existe el script?
    if [ ! -f "$rutabinario/$SCRIPT" ]; then
      incompleto=1
      faltantesBIN+=("$SCRIPT")
      echo "Falta el script $SCRIPT"
    fi

  done

  if [ $incompleto == 1 ]; then # Si el archivo esta incompleto
    return 0
  fi
  return 1  

}

function verificarPermisos() {
  permisos=0

  for SCRIPT in "${scripts[@]}"
  do
    chmod +x "$SCRIPT"
    if [ "$?" = -1 ]; then
      permisos=1
      msj="El archivo \"${SCRIPT}\" no tiene los permisos necesarios"
      $GRABITAC "$BINDIR/PrepararAmbiente.sh" "$msj" "ERR"
    fi
  done

  if [ $permisos == 1 ]; then
    # Los permisos no estan correctamente asignados
    return 0
  fi
  return 1
}

function repararInstalacion(){
  # Repara instalacion

  directorioRaiz=~/grupo02

  echo "Reparando carpetas.."

  carpetas=("$BINDIR" "$MAEDIR" "$ARRDIR" "$OKDIR" "$PROCDIR" "$PROCDIR/procesadas" "$PROCDIR/rechazadas" "$PROCDIR/sorteos" "$INFODIR" "$NOKDIR" "$CONFDIR")

  for I in ${faltantesCarpetas[*]}
  do
      mkdir "$I" &> /dev/null
  done

  echo "Copiando scripts faltantes.."
  for I2 in ${faltantesBIN[*]}
  do
    if [ -f $directorioRaiz/BIN/$I2 ]; then
      cp $directorioRaiz/BIN/$I2 $directorioRaiz/binarios/$I2
    fi
  done

  posicionActual=`pwd`

  echo "Copiando archivos faltantes.."
  for I3 in ${faltantesMAE[*]}
  do
    if [ -f $directorioRaiz/MAE/$I3 ]; then 
      cp $directorioRaiz/MAE/$I3 $directorioRaiz/maestros/$I3 
    fi
  done

}

# Muestra las variables de entorno y su contenido
function mostrarYGrabar() {


  variables=("$BINDIR" "$MAEDIR" "$ARRIDIR" "$OKDIR" "$PROCDIR" "$NOKDIR" "$LOGDIR")
  mensajes=("Ejecutables" "Maestros y Tablas" "Recepción de archivos de novedades" "Archivos aceptados" "Archivos de ofertas procesadas" "Archivos de ofertas rechazadas" "Archivos de Log" )
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
        echo "Modo de uso de comando LANZAR para iniciar RECIBIROFERTAS: LanzarProceso.sh RecibirOfertas" 
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


# Verifico que ambiente este seteado

# Funciones varias
source ~/grupo02/binarios/FuncionesVarias.sh

verificarAmbienteInicializado
ambienteIni=$?
if [ $ambienteIni == 0 ]; then
  MSJ="Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente"
  echo $MSJ
  "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "$MSJ" "ERR"
  return 1
fi

# Preparo el ambiente
if [ ! -f $CONFG ]; then
  MSJ="Archivo de configuracion borrado, se debe realizar la instalacion nuevamente o agregar bien el archivo"
  echo $MSJ
  "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "$MSJ" "ERR"
  return 1
fi
setearVariablesAmbiente


# Verifico y reparo instalacion

verificarInstalacion
instCompleta=$?
if [ $instCompleta == 0 ]; then

  repararInstalacion
  verificarInstalacion
  verificoReparacion=$?
  if [ $verificoReparacion == 0 ]; then
    unset GRUPO
    unset ARRIDIR
    unset BINDIR
    unset MAEDIR
    unset CONFDIR
    unset DATASIZE
    unset OKDIR
    unset INFODIR
    unset PROCDIR
    unset LOGDIR
    unset NOKDIR
    unset LOGSIZE
    unset LOCKDIR
    unset SLEEPTIME
    unset CONFDI
    echo "La instalación no se pudo reparar correctamente, se deberá volver a realizar la instalación"
    "$GRABITAC" "$BINDIR/PrepararAmbiente.sh" "$MSJ" "ERR"
    return 1
  fi
fi


# Verifico permisos
verificarPermisos
permisos=$?
if [ $permisos == 0 ]; then
  echo "Los permisos estan mal asignados"
  return 1
fi 

inicializarAmbiente

mostrarYGrabar
deseaLanzar


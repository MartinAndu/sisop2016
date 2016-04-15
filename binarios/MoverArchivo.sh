#!/bin/bash
# Mueve un archivo desde el origen al destino
# $1 path del archivo a mover
# $2 directorio destino
# $3 comando que lo invoca (opcional), se pasa como $0

GRALOG="./gralog.sh"

FILE=`basename $1`
DEST=$2
ORIG=`dirname $1`
CMD=$3

CMDGRABA="false"

function msjLog() {
  local MOUT=$1
  local TIPO=$2
  echo "${MOUT}"
  # Solo graba si se invoca por un comando que registre en su log
  if [[ ( ! -z $CMD ) && ( $CMDGRABA = "true" ) ]]; then
    $GRALOG "$CMD" "$MOUT" "$TIPO"
  fi
}

# Si mover.sh es invocada por un comando que graba en un archivo de log, registrar el resultado de su uso en el log del comando
if [ "$CMD" == "./afrainst.sh" ] || [ "$CMD" == "./afrainic.sh" ] || [ "$CMD" == "./afrareci.sh" ] || [ "$CMD" == "./afraumbr.sh" ] ; then
  CMDGRABA="true"
  MOUT="Se ha invocado al script mover.sh"
  $GRALOG "$CMD" "$MOUT" "INFO"
fi

# Revisa que se reciban si o si dos parametros
if [ $# -lt 2 ]; then
  MOUT="Se deben ingresar al menos dos parametros para Mover"
  msjLog "${MOUT}" "ERR"  
  exit 1
fi

# Revisa que el archivo a mover exista
if [ ! -f "$1" ]; then
  MOUT="El archivo a mover \"${FILE}\" no existe"
  msjLog "$MOUT" "ERR"
  exit 1
fi

# Revisa que el directorio destino exista
if [ ! -d "$DEST" ]; then
  MOUT="El destino \"${DEST}\" no existe"
  msjLog "$MOUT" "ERR"
  exit 1
fi

# Revisa si el path de origen y el de destino son iguales
if [ "$ORIG" = "$DEST" ]; then
  MOUT="Paths de origen y destino son iguales"
  msjLog "$MOUT" "ERR"
  exit 1
fi

# Revisa si ya existe un archivo con el mismo nombre
FILEDEST=$DEST/$FILE
DUPLI=$DEST/duplicados

if [ -f "$FILEDEST" ]; then
  MOUT="Ya existe un archivo con ese nombre en \"${DEST}\""
  msjLog "$MOUT" "WAR"
  # Si no existe DUPLICADOS, lo crea
  if [ ! -d ${DUPLI} ]
  then
    mkdir ${DUPLI}
    echo "El directorio \"${DUPLI}\" ha sido creado"
  fi
  
  # Ya existe DUPLICADOS
  if [ ! -f "$DUPLI"/"$FILE" ]; then
     mv "${1}" "${DUPLI}"
     echo "El archivo \"${FILE}\" ha sido movido a \"${DUPLI}\""
     exit 0
  else
    # tengo que depositarlo con secuencia nnn si ya se encuentra
    NNN=0 

    for ARCH in "${DUPLI}"/*    
    do
       if [ "${ARCH%%.*}" = "${DUPLI}"/"${FILE%%.*}" ]; then
        NNN=$(printf "%03d" $((NNN+1)))
      fi
    done
 
    NEWFILE="${DUPLI}"/"${FILE}"."${NNN}"
    mv "${1}" "${NEWFILE}"
    echo "El archivo \"$FILE\" ha sido movido con secuencia $NNN a duplicados"
    exit 0
  fi

else
  mv "${1}" "${DEST}"
  MOUT="El archivo \"${FILE}\" ha sido movido al directorio \"${DEST}\""
  msjLog "$MOUT" "INFO"
  exit 0
fi

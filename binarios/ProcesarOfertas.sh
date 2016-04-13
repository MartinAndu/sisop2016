#!/bin/bash

#GRABITAC="$BINDIR/grabarbitacora.sh"
#GRABITAC=$(pwd)"/grabarbitacora.sh"

#Se supone que esto despues no va y se usan las vars de ambiente
GRUPO="$(dirname "$PWD")" #simula la carpeta raiz
OKDIR="$GRUPO/aceptados"
MAEDIR="$GRUPO/maestros"
PROCDIR="$GRUPO/procesados"
NOKDIR="$GRUPO/rechazados"
LOGDIR="$GRUPO/bitacoras"
#

cantidadArchivosAceptados=`ls -A "$OKDIR" | wc -l`
echo "Inicio de ProcesarOfertas"
echo "Cantidad de archivos a procesar: $cantidadArchivosAceptados"
#Si no hay archivos para procesar
if [ $cantidadArchivosAceptados -eq 0 ] ; then
  echo "Cantidad de archivos procesados: $cantidadArchivosAceptados"
  echo "Cantidad de archivos rechazados: 0"
  echo "Fin de ProcesarOfertas"
  exit
fi

#Verifica el tipo de archivo
#este recorrido tengo que lograr ordenarlo por fechas antes
for archivoAceptado in `ls -A "$OKDIR"`
do
  tipoArchivo=`file -b --mime-type "$OKDIR/$archivoAceptado"`
  if [ $tipoArchivo = 'text/plain' ]
  then
    echo 'valido'
  else
    echo 'invalido'
    #mover a rechazados
  fi
done

#function msjLog() {
#  local MOUT=$1
#   local TIPO=$2
#   echo "${MOUT}"
#   $GRABITAC "$0" "$MOUT" "$TIPO"
# }
#
# msjLog "Inicio de ProcesarOfertas" "INFO"
# msjLog "Cantidad de archivos a procesar:$cantidad" "INFO"
#
#INPUT =

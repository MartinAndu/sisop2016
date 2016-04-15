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

function msjLog() {
  local MSJOUT=$1
  local TIPO=$2
  echo "${MSJOUT}"
  #$GRABITAC "$0" "$MSJOUT" "$TIPO"
}

function EsArchivoDeTextoPlano(){
  local archivo=$1
  tipoArchivo=$(file -b --mime-type "$OKDIR/$archivoAceptado")
  if [ $tipoArchivo = 'text/plain' ]
  then
    echo 'es de texto plano'
    return 0 #TRUE
  else
    echo 'NO es de texto plano'
    return 1 #FALSE
  fi
}

function EsArchivoDuplicado(){
  local archivo=$1
  if [ -f "$PROCDIR/procesadas/$archivo" ]
  then
    msjLog "Se rechaza el archivo por estar DUPLICADO" "INFO"
    #MoverArchivos $archivo $NOKDIR
    #cantidadArchivosRechazados +=1
    return 0 #TRUE
  else
    echo "NO DUPLICADO" #NO VA
    return 1 #FALSE
  fi
}

#PENDIENTE
function EsEstructuraInvalida(){
  local archivo=$1
  echo 'ESTRUCTURA VALIDA'
  return 1 #FALSE
}

function EsOfertaValida(){
  local registro=$1
  echo 'Es valida'
  return 0 #TRUE
}

function RechazarRegistro(){
  local registro=$1
  echo 'RechazarRegistro'
}

function GrabarOfertaValida(){
  local registro=$1
  echo 'RechazarRegistro'
}

function Procesar(){
  local archivo=$1
  for registro in $registrosArchivo
  do
  if EsOfertaValida $registro
  then
    #GrabarOfertaValida $registro
    #incrementar contadores adecuados
    echo 'oferta valido' #nova
  else
    #RechazarRegistro $registro
    #incrementar contadores adecuados
    echo 'registro rechazado' #nova
  fi
  done
  msjLog "Registros leídos = $aaa; Cantidad de ofertas válidas $bbb; Cantidad de ofertas rechazadas = $ccc" "INFO"
}

function FinProceso() {
  local cantidadArchivosProcesados=$1
  local cantidadArchivosRechazados=$2
  msjLog "Cantidad de archivos procesados: $cantidadArchivosProcesados" "INFO"
  msjLog "Cantidad de archivos rechazados: $cantidadArchivosRechazados" "INFO"
  msjLog "Fin de ProcesarOfertas" "INFO"
  exit
}

cantidadArchivosProcesados=0
cantidadArchivosRechazados=0
cantidadArchivosAProcesar=$(ls -A "$OKDIR" | wc -l)
msjLog "Inicio de ProcesarOfertas" "INFO"
msjLog "Cantidad de archivos a procesar:$cantidadArchivosAProcesar" "INFO"
#echo "Inicio de ProcesarOfertas"
#echo "Cantidad de archivos a procesar: $cantidadArchivosAProcesar"
echo ''

# Ordeno los archivos cronologicamente (mas antiguo al mas reciente) y los proceso
archivosOrdenados=$(ls -A "$OKDIR" | sed 's-^\(.*\)\([0-9]\{8\}\).csv$-\2\1.csv-g' | sort | sed 's-^\([0-9]\{8\}\)\(.*\).csv$-\2\1.csv-g')
for archivo in $archivosOrdenados
do
  echo $archivo #NO VA
  if EsArchivoDuplicado $archivo || EsEstructuraInvalida $archivo # && [!EsEstructuraInvalida $archivo]
  then
    #MoverArchivos $archivo $NOKDIR
    echo "Mover archivo a NOKDIR"
  else
    msjLog "Archivo a procesar: $archivo" "INFO"
    #Procesar $archivo
  fi
  #Resetear contadores de registros
  echo '' #NO VA
done

FinProceso $cantidadArchivosProcesados $cantidadArchivosRechazados

exit
#Ya termino el programa

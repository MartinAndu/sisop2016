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

function FinProceso() {
  local cantidadArchivosProcesados=$1
  local cantidadArchivosRechazados=$2
  echo "Cantidad de archivos procesados: $cantidadArchivosProcesados"
  echo "Cantidad de archivos rechazados: $cantidadArchivosRechazados"
  echo "Fin de ProcesarOfertas"
  exit
}

function msjLog() {
  local MSJOUT=$1
  local TIPO=$2
  echo "${MSJOUT}"
  #$GRABITAC "$0" "$MSJOUT" "$TIPO"
}

function Rechazar(){
  echo 'Rechazar'
}

function ValidarQueSePuedaProcesar(){
  #local archivo=$1
  #local resultadoEvaluacion=$?
  #VerificarDuplicado $archivo
  #VerificarCamposPrimerRegistro $archivo
  echo "validando.."
  return $TRUE
}

function VerificarDuplicado(){
  local archivo=$1
  if [ -f $PROCDIR/procesadas/$archivo ]
  then
    #archivo duplicado
    msjLog "Se rechaza el archivo por estar DUPLICADO" "INFO"
    #MoverArchivos $archivo $NOKDIR
    #cantidadArchivosRechazados +=1
  else
    echo valido
     #valido
  fi
}

function VerificarCamposPrimerRegistro(){
  echo 'VerificarCamposPrimerRegistro'
}

cantidadArchivosAProcesar=$(ls -A "$OKDIR" | wc -l)
# msjLog "Inicio de ProcesarOfertas" "INFO"
# msjLog "Cantidad de archivos a procesar:$cantidadArchivosAProcesar" "INFO"
echo "Inicio de ProcesarOfertas"
echo "Cantidad de archivos a procesar: $cantidadArchivosAProcesar"

#Si no hay archivos para procesar finalizar
if [ $cantidadArchivosAProcesar -eq 0 ] ; then
  FinProceso 0 0
fi

# Ordeno los archivos cronologicamente (mas antiguo al mas reciente) y los proceso
archivosOrdenados=$(ls -A "$OKDIR" | sed 's-^\(.*\)\([0-9]\{8\}\).csv$-\2\1.csv-g' | sort | sed 's-^\([0-9]\{8\}\)\(.*\).csv$-\2\1.csv-g')
for archivo in $archivosOrdenados
do
  echo $archivo
  esValido=$(ValidarQueSePuedaProcesar) #$archivo
  if [$esValido eq $TRUE]
  then
    msjLog "Archivo a procesar: $archivo" "INFO"
  else
    echo 'mover a NOKDIR'
  fi
done
exit

# for fileName in $inputFiles;
# do
#   procesarArchivo $fileName
#   if [ "$?" = 0 ]; then	# si no fue procesado, sigo
#     validarPrimerRegistro $fileName
#     if [ "$?" = 0 ]; then
#       # 3. Si se puede procesar el archivo
#       msjLog "Archivo a procesar: $fileName" "INFO"
# # Empiezo a procesar cada registro
# procesarRegistro $fileName
# finDeArchivo $fileName
#     fi
#   fi
# done



#Verifica el tipo de archivo
#este recorrido tengo que lograr ordenarlo por fechas antes
# for archivoAceptado in $(ls -A "$OKDIR")
# do
#   tipoArchivo=$(file -b --mime-type "$OKDIR/$archivoAceptado")
#   if [ $tipoArchivo = 'text/plain' ]
#   then
#     echo 'valido'
#   else
#     echo 'invalido'
#     #mover a rechazados
#   fi
# done

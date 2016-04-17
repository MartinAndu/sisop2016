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
  echo -e "${MSJOUT}"
  #$GRABITAC "$0" "$MSJOUT" "$TIPO"
}

function EsArchivoDeTextoPlano(){
  local archivo=$1
  local tipoArchivo=$(file -b --mime-type "$OKDIR/$archivo")
  #echo "Tipo del archivo: $tipoArchivo (NOVA)" #NOVA
  if [ $tipoArchivo = 'text/plain' ] ; then
    return 0 #TRUE
  else
    return 1 #FALSE
  fi
}

function EsArchivoDuplicado(){
  local archivo=$1
  if [ -f "$PROCDIR/procesadas/$archivo" ] ; then
    return 0 #TRUE
  else
    return 1 #FALSE
  fi
}

#PREGUNTAR: NOSE si tiene que ser numeros sin coma o con coma
function EsEstructuraInvalida(){
  local archivo=$1
  if EsArchivoDeTextoPlano $archivo ; then
    local esCampoValido=$(head -n 1 "$OKDIR/$archivo" | grep -c "^[0-9]\{7\}\;[0-9]\+$")
    if [ $esCampoValido -eq 1 ] ; then
      return 1 #FALSE
    else
      return 0 #TRUE
    fi
  else
    return 0 #TRUE
  fi
}

function RechazarArchivo(){
  local archivo=$1
  #MoverArchivo "$OKDIR/$archivo" "$NOKDIR"
  cantidadArchivosRechazados=$(($cantidadArchivosRechazados+1))
}

#PENDIENTE
#PREGUNTAR a que se refiere con 'contrato no encontrado'
function EsOfertaValida(){
  local contratoFusionado=$1
  local importeOferta=$2
  local grupo=$(echo $contratoFusionado | sed 's-^\([0-9]\{4\}\)[0-9]\{3\}$-\1-g')
  #echo "NroGrupo: $grupo" #NOVA
  local orden=$(echo $contratoFusionado | sed 's-^[0-9]\{4\}\([0-9]\{3\}\)$-\1-g')
  #echo "NroOrden: $orden" #NOVA
  local lineaGruposCsv=$(grep "^$grupo;" "$MAEDIR/Grupos.csv")
  #echo "lineaGrupo: $lineaGruposCsv"
  local estadoGrupo=$(echo "$lineaGruposCsv" | cut -f2 -d';')
  echo "estadoGrupo: $estadoGrupo" #NOVA
  local valorCuotaPura=$(echo "$lineaGruposCsv" | cut -f4 -d';' | sed 's-,-\.-g')
  #echo "valorCuotaPura: $valorCuotaPura" #NOVA
  local cantidadCuotasPendientes=$(echo "$lineaGruposCsv" | cut -f5 -d';')
  #echo "cantidadCuotasPendientes: $cantidadCuotasPendientes" #NOVA
  local cantidadCuotasLicitacion=$(echo "$lineaGruposCsv" | cut -f6 -d';')
  #echo "cantidadCuotasLicitacion: $cantidadCuotasLicitacion" #NOVA
  local montoMinimo=$(echo "$valorCuotaPura*$cantidadCuotasLicitacion" | bc)
  echo "montoMinimo: $montoMinimo" #NOVA
  local montoMaximo=$(echo "$valorCuotaPura*$cantidadCuotasPendientes" | bc)
  echo "montoMaximo: $montoMaximo" #NOVA
  echo "importeOferta: $importeOferta" #NOVA
  #local flagParticipa

  local motivoRechazo=''
  if [ $(echo "$importeOferta>=$montoMinimo" | bc) -ne 1 ] ; then # 1 TRUE
    motivoRechazo=$motivoRechazo'No alzanza el monto mínimo. '
  fi

  if [ $(echo "$importeOferta<=$montoMaximo" | bc) -ne 1 ] ; then # 1 TRUE
    motivoRechazo=$motivoRechazo'Supera el monto máximo. '
  fi

  echo "estadoGrupo=$estadoGrupo" #NOVA
  if [ "$estadoGrupo" = "CERRADO" ] ; then
    motivoRechazo=$motivoRechazo'Grupo CERRADO. '
  fi

  #Falta contrato no encontrado
  #Suscriptor no puede participar

  if [ "$motivoRechazo" = '' ] ; then
    return 0 #TRUE
  else
    #Quizas el RechazarRegistro podria ir aca asi paso el parametro motivoRechazo sin tanto problema
    #RechazarRegistro
    echo 'motivoRechazo: '$motivoRechazo
    return 1 #FALSE
  fi
}

#PENDIENTE
function RechazarRegistro(){
  local registro=$1
  echo 'RechazarRegistro'
}

#PENDIENTE
function GrabarOfertaValida(){
  local registro=$1
  echo 'RechazarRegistro'
}

function Procesar(){
  local archivo=$1
  local cantidadRegistrosLeidos=0
  local cantidadRegistrosValidos=0
  local cantidadRegistrosRechazados=0
  local IFS=";"
  while read contratoFusionado importeOferta ; do
    echo ''
    cantidadRegistrosLeidos=$(($cantidadRegistrosLeidos+1))
    if EsOfertaValida $contratoFusionado $importeOferta ; then
      echo "GRABAR oferta valida" #NOVA
      #GrabarOfertaValida
      cantidadRegistrosValidos=$(($cantidadRegistrosValidos+1))
    else
      echo "RECHAZAR registro" #NOVA
      #RechazarRegistro
      cantidadRegistrosRechazados=$(($cantidadRegistrosRechazados+1))
    fi
  done < "$OKDIR/$archivo"
  msjLog "Cantidad de registros leídos:\t$cantidadRegistrosLeidos" "INFO"
  msjLog "Cantidad de ofertas válidas:\t$cantidadRegistrosValidos" "INFO"
  msjLog "Cantidad de ofertas rechazadas:\t$cantidadRegistrosRechazados" "INFO"
  #MoverArchivo "$OKDIR/$archivo" "$PROCDIR/procesadas"
  cantidadArchivosProcesados=$(($cantidadArchivosProcesados+1))
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
msjLog "Cantidad de archivos a procesar: $cantidadArchivosAProcesar" "INFO"
#echo "Inicio de ProcesarOfertas"
#echo "Cantidad de archivos a procesar: $cantidadArchivosAProcesar"
echo ''

#Ordeno los archivos cronologicamente (mas antiguo al mas reciente) y los proceso
archivosOrdenados=$(ls -A "$OKDIR" | sed 's-^\(.*\)\([0-9]\{8\}\).csv$-\2\1.csv-g' | sort | sed 's-^\([0-9]\{8\}\)\(.*\).csv$-\2\1.csv-g')
for archivo in $archivosOrdenados ; do
  #echo $archivo #NO VA
  if EsArchivoDuplicado $archivo ; then
    RechazarArchivo $archivo
    msjLog "Archivo rechazado:  '$archivo' (está DUPLICADO)" "INFO"
  elif EsEstructuraInvalida $archivo ; then
    RechazarArchivo $archivo
    msjLog "Archivo rechazado:  '$archivo' (estructura no correspondida con el formato esperado)" "INFO"
  else
    msjLog "Archivo a procesar: '$archivo'" "INFO"
    Procesar $archivo
  fi



  #Resetear contadores de registros
  echo '' #NOVA
done

FinProceso $cantidadArchivosProcesados $cantidadArchivosRechazados

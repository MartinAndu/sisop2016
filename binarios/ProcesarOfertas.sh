#!/bin/bash
source FuncionesVarias.sh

GRABITAC="$BINDIR/GrabarBitacora.sh"
MOVER="$BINDIR/MoverArchivo.sh"



function verificarAmbiente(){
    ambienteInicializado 
    if [ $? == 1 ]; then
      local mensajeError="Ambiente no inicializado"
      echo "$mensajeError":"ERR"
      exit 1
    fi
}


function msjLog() {
  local MSJOUT=$1
  local TIPO=$2
  #echo -e "${MSJOUT}"
  "$GRABITAC" "$0" "${MSJOUT}" "$TIPO"
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

#TODO: PREGUNTAR: NOSE si tiene que ser numeros sin coma o con coma
function EsEstructuraInvalida(){
  local archivo=$1
  if EsArchivoDeTextoPlano $archivo ; then
    read -r primeraLinea < "$OKDIR/$archivo"
    #echo primeraLinea: $primeraLinea
    local esCampoValido=$(echo -e $primeraLinea | grep -c "^[0-9]\{7\};[0-9]\+\([,][0-9]\+\)\?$")
    #echo esCampoValido: $esCampoValido

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
  "$MOVER" "$OKDIR/$archivo" "$NOKDIR/"
  cantidadArchivosRechazados=$(($cantidadArchivosRechazados+1))
}

function EsOfertaValida(){
  motivoRechazo='' #La uso como variable global
  local contratoFusionado=$1
  #echo contratoFusionado: $contratoFusionado
  local importeOfertaTmp=$2
  local importeOferta=$(echo "$importeOfertaTmp" | sed 's/,/\./g')
  #local importeOferta=$2
  # echo importeOFerta: $importeOferta

  local grupo=$(echo $contratoFusionado | sed 's-^\([0-9]\{4\}\)[0-9]\{3\}$-\1-g')
  #echo "NroGrupo: $grupo" #NOVA
  local orden=$(echo $contratoFusionado | sed 's-^[0-9]\{4\}\([0-9]\{3\}\)$-\1-g')
  #echo "NroOrden: $orden" #NOVA

  if [ $(grep -c "^$grupo;" "$MAEDIR/Grupos.csv") -eq 0 ] ; then
    motivoRechazo=$motivoRechazo'Grupo no encontrado. '
  else
    local lineaGruposCsv=$(grep "^$grupo;" "$MAEDIR/Grupos.csv")
    #echo "lineaGrupo: $lineaGruposCsv"
    local estadoGrupo=$(echo "$lineaGruposCsv" | cut -f2 -d';')
    # echo "estadoGrupo: $estadoGrupo" #NOVA
    local valorCuotaPura=$(echo "$lineaGruposCsv" | cut -f4 -d';' | sed 's-,-\.-g')
    # echo "valorCuotaPura: $valorCuotaPura" #NOVA
    local cantidadCuotasPendientes=$(echo "$lineaGruposCsv" | cut -f5 -d';')
    # echo "cantidadCuotasPendientes: $cantidadCuotasPendientes" #NOVA
    local cantidadCuotasLicitacion=$(echo "$lineaGruposCsv" | cut -f6 -d';')
    # echo "cantidadCuotasLicitacion: $cantidadCuotasLicitacion" #NOVA
    local montoMinimo=$(echo "$valorCuotaPura*$cantidadCuotasLicitacion" | bc)
    # echo "montoMinimo: $montoMinimo" #NOVA
    local montoMaximo=$(echo "$valorCuotaPura*$cantidadCuotasPendientes" | bc)
    # echo "montoMaximo: $montoMaximo" #NOVA

    if [ $(echo "$importeOferta>=$montoMinimo" | bc) -ne 1 ] ; then # 1 TRUE
      motivoRechazo=$motivoRechazo'No alzanza el monto mínimo. '
    fi

    if [ $(echo "$importeOferta<=$montoMaximo" | bc) -ne 1 ] ; then # 1 TRUE
      motivoRechazo=$motivoRechazo'Supera el monto máximo. '
    fi

    if [ "$estadoGrupo" = "CERRADO" ] ; then
      motivoRechazo=$motivoRechazo'Grupo CERRADO. '
    fi
  fi

  if [ $(grep -c "^$grupo;$orden;" "$MAEDIR/temaL_padron.csv") -eq 0 ] ; then
    motivoRechazo=$motivoRechazo'Contrato no encontrado. '
  else
    local lineaPadronCsv=$(grep "^$grupo;$orden;" "$MAEDIR/temaL_padron.csv")
    #echo "lineaPadronCsv: $lineaPadronCsv"
    local flagParticipa=$(echo "$lineaPadronCsv" | cut -f6 -d';')
    #echo "flagParticipa: $flagParticipa"

    if [ "$flagParticipa" = " " ] ; then
      motivoRechazo=$motivoRechazo'Suscriptor no puede participar. '
    fi
  fi

  if [ "$motivoRechazo" = '' ] ; then
    return 0 #TRUE
  else
    #echo 'motivoRechazo: '$motivoRechazo
    return 1 #FALSE
  fi
}

function RechazarRegistro(){
  local fuente=$1
  local registroOriginalCompleto="\"$2;$3\""
  local usuario=$(whoami)
  local fecha=$(date +"%y/%m/%d %H:%M:%S")
  local codConcecionario=$(echo $archivo | cut -f1 -d'_')
  local concecionario=$(echo $archivo | cut -f2 -d'_')
  local archivoSalida="$codConcecionario"_"$concecionario".rech
  echo "$fuente;$motivoRechazo;$registroOriginalCompleto;$usuario;$fecha" >> "$PROCDIR/rechazadas/$archivoSalida"

  #NOVA
  # echo "RechazarRegistro     > $archivoSalida"
  # echo "Fuente               : $fuente"
  # echo "Motivo Rechazo       : $motivoRechazo"
  # echo "Registro de Oferta   : $registroOriginalCompleto"
  # echo "Usuario              : $usuario"
  # echo "Fecha                : $fecha"
  #NOVA
}

function GrabarOfertaValida(){
  local archivo=$1
  local fechaArchivo=$(echo $archivo | sed 's-^.*\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\.csv$-\1/\2/\3-g')
  local codConcecionario=$(echo $archivo | cut -f1 -d'_')
  local contratoFusionado=$2
  local grupo=$(echo $contratoFusionado | sed 's-^\([0-9]\{4\}\)[0-9]\{3\}$-\1-g')
  local orden=$(echo $contratoFusionado | sed 's-^[0-9]\{4\}\([0-9]\{3\}\)$-\1-g')
  local importeOfertaTmp=$3
  local importeOferta=$(echo "$importeOfertaTmp" | sed 's/,/\./g')
  #local importeOferta=$(echo "$importeOfertaTmp" | cut -f1 -d',').$(echo "$importeOfertaTmp" | cut -f2 -d',')

  local lineaPadronCsv=$(grep "^$grupo;$orden;" "$MAEDIR/temaL_padron.csv")
  local nombreSuscriptor=$(echo "$lineaPadronCsv" | cut -f3 -d';')
  local usuario=$(whoami)
  local fecha=$(date +"%y/%m/%d %H:%M:%S")

  local fechaProximoActoAdjudicacion=$("$BINDIR/ProximaFechaAdj.sh")

  fechaProximoActoAdjudicacion=$(date -d"@$fechaProximoActoAdjudicacion" +%Y%m%d)
  echo "$codConcecionario;$fechaArchivo;$contratoFusionado;$grupo;$orden;$importeOfertaTmp;$nombreSuscriptor;$usuario;$fecha" >> "$PROCDIR/validas/$fechaProximoActoAdjudicacion"".txt"

  #NOVA
  # echo "GrabarOfertaValida   > $fechaProximoActoAdjudicacion"".txt"
  # echo "Codigo Concecionario : $codConcecionario"
  # echo "Fecha Archivo        : $fechaArchivo"
  # echo "Contrato Fusionado   : $contratoFusionado"
  # echo "Grupo                : $grupo"
  # echo "Nro de Orden         : $orden"
  # echo "Importe Ofertado     : $importeOferta"
  # echo "Nombre del Suscriptor: $nombreSuscriptor"
  # echo "Usuario              : $usuario"
  # echo "Fecha                : $fecha"
  # #NOVA
}

function Procesar(){
  local archivo=$1
  local cantidadRegistrosLeidos=0
  local cantidadRegistrosValidos=0
  local cantidadRegistrosRechazados=0

  while IFS='' read -r line || [[ -n "$line" ]]; do
    local contratoFusionado=$(echo "$line" | cut -f1 -d';')
    local importeOferta=$(echo "$line" | cut -f2 -d';')
    # echo ''
    cantidadRegistrosLeidos=$(($cantidadRegistrosLeidos+1))
    if EsOfertaValida $contratoFusionado $importeOferta ; then
      # echo "GRABAR oferta valida" #NOVA
      GrabarOfertaValida $archivo $contratoFusionado $importeOferta
      cantidadRegistrosValidos=$(($cantidadRegistrosValidos+1))
    else
      # echo "RECHAZAR registro" #NOVA
      RechazarRegistro $archivo $contratoFusionado $importeOferta $motivoRechazo
      motivoRechazo='' #Reseteamos el motivo
      cantidadRegistrosRechazados=$(($cantidadRegistrosRechazados+1))
    fi
  done < "$OKDIR/$archivo"

  # echo '' #NOVA
  msjLog "Cantidad de registros leídos:\t$cantidadRegistrosLeidos" "INFO"
  msjLog "Cantidad de ofertas válidas:\t$cantidadRegistrosValidos" "INFO"
  msjLog "Cantidad de ofertas rechazadas:\t$cantidadRegistrosRechazados" "INFO"
  "$MOVER" "$OKDIR/$archivo" "$PROCDIR/procesadas/"
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

verificarAmbiente

cantidadArchivosProcesados=0
cantidadArchivosRechazados=0
cantidadArchivosAProcesar=$(ls -A "$OKDIR" | wc -l)
msjLog "Inicio de ProcesarOfertas" "INFO"
msjLog "Cantidad de archivos a procesar: $cantidadArchivosAProcesar" "INFO"
# echo '' #NOVA

#Ordeno los archivos cronologicamente (mas antiguo al mas reciente) y los proceso
archivosOrdenados=$(ls -A "$OKDIR" | sed 's-^\(.*\)\([0-9]\{8\}\)\.csv$-\2\1.csv-g' | sort | sed 's-^\([0-9]\{8\}\)\(.*\)\.csv$-\2\1.csv-g')
for archivo in $archivosOrdenados ; do
  #echo $archivo #NO VA
  if EsArchivoDuplicado $archivo ; then
    RechazarArchivo $archivo
    msjLog "Archivo rechazado:  '$archivo' (está DUPLICADO)" "WAR"
  elif EsEstructuraInvalida $archivo ; then
    RechazarArchivo $archivo
    msjLog "Archivo rechazado:  '$archivo' (estructura no correspondida con el formato esperado)" "WAR"
  else
    msjLog "Archivo a procesar: '$archivo'" "INFO"
    Procesar $archivo
  fi
  # echo '' #NOVA
done

FinProceso $cantidadArchivosProcesados $cantidadArchivosRechazados

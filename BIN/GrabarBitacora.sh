#!/bin/bash
# Registro oficial de logs
# $1 comando que lo invoca
# $2 mensaje
# $3 tipo de mensaje

# Revisa que se reciban si o si dos parametros

if [ $# -lt 2 ]; then
  echo "Se deben ingresar al menos dos parametros"
  exit 1
fi

CMDO=$1
MSJE=$2
TIPO=$3        		# INFO, WAR, ERR


TRUNCO=50		# Lineas que me guardo al truncar

bytes=1024

CMDO2=$(echo $CMDO | sed "s|^.*\/\(.*\).sh$|\1|g")

#NOVA {
LOGDIR="$GRUPO/bitacoras"
FILE="${LOGDIR}"/"${CMDO2}.log"


WHEN=`date +%T-%d-%m-%Y`
WHO=${USER}

# Si el tamanio del archivo de log es mayor que $LOGSIZE, guardo las últimas $TRUNCO líneas


tamaniomaximo=$((${LOGSIZE} * ${bytes}))	# Tamanio máximo en bytes
if [ -f "$FILE" ];then
	tamanioactual=$(wc -c <"$FILE")
fi

if [[ "${tamanioactual}" -ge "${tamaniomaximo}" ]]; then
  sed -i "1,$(($(wc -l $FILE|awk '{print $1}') - $TRUNCO)) d" "$FILE"
  echo -e $WHEN - $WHO - $CMDO2 - "INFO" - "Log Excedido" >> "$FILE"
fi

echo -e "$WHEN - $WHO - $CMDO2 - $TIPO - $MSJE" >> "$FILE"

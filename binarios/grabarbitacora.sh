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

CMDO2=`echo $CMDO | sed "s/^.*\/\(^[a-z]*\).sh$/\1/"`
FILE=$(awk)${CMDO2}.log

# TODO: el PATH del FILE  no esta bien, esta harcodeado porque no existe la variable de ambiente aun

echo $FILE
WHEN=`date +%T-%d-%m-%Y` 
WHO=${USER}

# Si el tamanio del archivo de log es mayor que $LOGSIZE, guardo las últimas $TRUNCO líneas

LOGSIZE=100
# TODO : el logsize se define en el prepararAmbiente, aca esta harcodeado para que ande  

tamaniomaximo=$((${LOGSIZE} * ${bytes}))	# Tamanio máximo en bytes
if [ -f $FILE ];then      
	tamanioactual=$(wc -c <"$FILE")		
fi

if [[ "${tamanioactual}" -ge "${tamaniomaximo}" ]]; then
  sed -i "1,$(($(wc -l $FILE|awk '{print $1}') - $TRUNCO)) d" $FILE
  echo $WHEN - $WHO - $CMDO - "INFO" - "Log Excedido" >> $FILE 
fi

echo $WHEN - $WHO - $CMDO - $TIPO - $MSJE >> $FILE 			


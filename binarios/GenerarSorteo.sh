#!/bin/bash

IFS='
'
TRUE=0
FALSE=1

GRABITAC=$(pwd)"/grabarbitacora.sh"
MOVER=$(pwd)"/mover.sh"

function msjLog() {
  local MOUT=$1
  local TIPO=$2
  echo "${MOUT}"
  $GRABITAC "$0" "$MOUT" "$TIPO"
}

#Se supone que esto despues no va y se usan las vars de ambiente
GRUPO="$(dirname "$PWD")" #simula la carpeta raiz
ARRIDIR=$GRUPO
MAEDIR=$GRUPO"/maestros"
PROCDIR=$GRUPO"/procesados"

#verifico que haya archivos en MAEDIR
if [ ! -d $MAEDIR ]; then
	echo "maestros=$MAEDIR"
	echo "La carpeta no existe. "
	exit
fi

fechaUltimoActoAdjudicacion=$(cut "$MAEDIR/FechasAdj.csv" -d';' -f1)
fechaActual=`date +%Y%m%d`
fechaProxima=0

	# se averigua el proximo acto de adjudicacion
	for fecha in $fechaUltimoActoAdjudicacion
	do
		fecha=`echo $fecha | sed 's-\([0-9]*\)/\([0-9]*\)/\([0-9]*\)$-\2/\1/\3-g'`
		fecha_=$(date -d "$fecha" +%Y%m%d)
		if [ $fecha_ -ge $fechaActual ] ; then
			fechaProxima=$fecha_
			echo "fechaProxima=$fechaProxima"
			break
		fi
	done


idActual="1"
SorteoId=ls $PROCDIR/sorteos/ | cut -d'_' -f 1

# Chequeo de nombres para sorteo id. Si ya existe el archivo, incrementa la variable en 1. 
if [ -d $PROCDIR/sorteos/"$SorteoId""_""$fechaProxima"".txt" ]; then
idActual=`echo "$SorteoId + 1" | bc`
fi

#idViejo=`echo "$idViejo + 1" | bc`; echo "total=" $idViejo


SorteoId=$idActual


fechaProxima=$(date -d "$fecha" +%Y%m%d)
touch $PROCDIR/sorteos/"$SorteoId""_""$fechaProxima"".txt"

for (( i=1;i<=168;i++ )) do 
echo $RANDOM  $((j++)); 
done|sort -k1|cut -d" " -f2 | nl -w1 -s\;> $PROCDIR/sorteos/"$SorteoId""_""$fechaProxima"".txt"|head -168


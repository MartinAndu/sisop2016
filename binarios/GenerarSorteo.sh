#!/bin/bash

IFS='
'
TRUE=0
FALSE=1

GRABITAC="$BINDIR/GrabarBitacora.sh"
function msjLog() {
  local MSJOUT=$1
  local TIPO=$2
  echo -e "${MSJOUT}"
  "$GRABITAC" "$0" "${MSJOUT}" "$TIPO"
}


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

for archivo in  `ls -A "$PROCDIR/sorteos"`
do
    SorteoId=$(echo $archivo | cut -d'_' -f1)
    if [ $SorteoId = $idActual ]; then
        idActual=`echo "$SorteoId+1" | bc`
    fi
done

SorteoId=$idActual
msjLog "Inicio de Sorteo" "INFO"
fechaProxima=$(date -d "$fecha" +%Y%m%d)
touch $PROCDIR/sorteos/"$SorteoId""_""$fechaProxima"".srt"
j=1
for (( i=1;i<=168;i++ )) do 
echo $RANDOM  $((j++))
done|sort -k1|cut -d" " -f2 | nl -w1 -s\;> $PROCDIR/sorteos/"$SorteoId""_""$fechaProxima"".srt"| head -168
msjLog "Fin de Sorteo" "INFO"



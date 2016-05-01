#!/bin/bash

proximaFechaAdj=$(date +%s)
proximaFechaAdj=`echo $proximaFechaAdj + 100000000 | bc`
for fecha in `cut "$MAEDIR/FechasAdj.csv" -d';' -f1`
do
	fechaModificada=$(echo $fecha | sed 's-\([0-9]*\)/\([0-9]*\)/\([0-9]*\)$-\2/\1/\3-g')
	fechaUnix=$(date -d"$fechaModificada" +%s)
	fechaActual=$(date +%s)
	#echo "fechaUnix=$fechaUnix"
	#echo "fechaModificada=$fechaModificada"
	#echo "fecha=$fecha"
	if [  $fechaUnix -ge $fechaActual -a  $fechaUnix -le $proximaFechaAdj ]
	then
		proximaFechaAdj=$fechaUnix
	fi
done
echo $proximaFechaAdj

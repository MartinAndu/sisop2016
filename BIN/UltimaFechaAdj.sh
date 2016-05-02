#!/bin/bash

ultimaFechaAdj=0
for fecha in `cut "$MAEDIR/FechasAdj.csv" -d';' -f1`
do
	fechaModificada=$(echo $fecha | sed 's-\([0-9]*\)/\([0-9]*\)/\([0-9]*\)$-\2/\1/\3-g')
	fechaUnix=$(date -d"$fechaModificada" +%s)
	fechaActual=$(date +%s)
	if [  $fechaUnix -le $fechaActual -a $fechaUnix -ge $ultimaFechaAdj ]
	then
		ultimaFechaAdj=$fechaUnix
	fi
done
echo $ultimaFechaAdj


#Prepara Ambiente

GRABITAC=$(pwd)"/binarios/GrabarBitacora.sh"
MOVER=$(pwd)"/binarios/mover.sh"


AFRACONFIG=$(pwd)"/CONFDIR/CIPAL.conf"
	

escribirConfig () {
	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}

	#GRUPO
	echo "GRUPO=$GRUPO=$WHO=$WHEN" >> $AFRACONFIG
	#CONFDIR
	echo "CONFDIR=$GRUPO/$CONFDIR=$WHO=$WHEN" >> $AFRACONFIG
	#BINDIR
	echo "BINDIR=$GRUPO/$BINDIR=$WHO=$WHEN" >> $AFRACONFIG
	#MAEDIR
	echo "MAEDIR=$GRUPO/$MAEDIR=$WHO=$WHEN" >> $AFRACONFIG
	#NOVEDIR
s
# Desde el archivo de configuración tomo todas las variables
function setearVariablesAmbiente() {
	echo "sds"
}




MSJ="Prueba Log Sorteo 2016"
echo "${MSJ}"
$GRABITAC "$0" "${MSJ}" "INFO"

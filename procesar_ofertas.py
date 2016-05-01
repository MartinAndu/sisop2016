import os

def procesar_ofertas():
	print "----------------------"
	print "INICIO PRUEBAS RECIBIR OFERTAS"
	os.system("bash binarios/ProcesarOfertas.sh > real_stdout_RecibirOfertas ; \
				echo PRUEBA DE MOVIMIENTO A PROCESADAS; \
				python test_mover_archivos_procesar.py 3500_20160415.csv TRUE ; \
				echo ; \
				echo PRUEBA DE MOVIMIENTO A RECHAZADAS POR SER DUPLICADO; \
				python test_mover_archivos.py 3500_20160416.csv FALSE ; \
				echo ; \
				echo PRUEBA DE MOVIMIENTO A RECHAZADAS POR CANTIDAD DE CAMPOS INCORRECTA; \
				python test_mover_archivos_procesar.py 3500_20160417.csv FALSE ; \
				echo ; \
				")

procesar_ofertas()
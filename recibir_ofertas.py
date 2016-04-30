import os

def recibir_ofertas():
	print "----------------------"
	print "INICIO PRUEBAS RECIBIR OFERTAS"
	os.system("bash binarios/RecibirOfertas.sh > real_stdout_RecibirOfertas ; \
				echo PRUEBA DE IMAGEN; \
				python test_mover_archivos.py imagen.png FALSE ; \
				echo ; \
				echo PRUEBA DE NOMBRE QUE NO RESPETA EL FORMATO; \
				python test_mover_archivos.py invalido.csv FALSE ; \
				echo ; \
				echo PRUEBA DE CODIGO DE CONCESIONARIO INVALIDO; \
				python test_mover_archivos.py 0000_20151225.csv FALSE ; \
				echo ; \
				echo PRUEBA DE FECHA INVALIDA CINCUENTA DE FEBRERO; \
				python test_mover_archivos.py 3500_20150250.csv FALSE ; \
				echo ; \
				echo PRUEBA DE FECHA POSTERIOR A LA ACTUAL; \
				python test_mover_archivos.py 3500_20171225.csv FALSE ; \
				echo ; \
				echo PRUEBA DE ARCHIVO VACIO; \
				python test_mover_archivos.py 3500_20151225.csv FALSE ; \
				echo ; \
				echo PRUEBA ARCHIVO VALIDO; \
				python test_mover_archivos.py 3500_20151230.csv TRUE ; \
				echo ; \
				echo ----------------------")

recibir_ofertas()

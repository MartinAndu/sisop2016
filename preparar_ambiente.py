import os

def preparar_ambiente():
	print "----------------------"
	print "INICIO PRUEBAS PREPARAR AMBIENTE"
	print "PRIMER CORRIDA NORMAL"
	os.system("bash binarios/PrepararAmbiente.sh > real_stdout_PrepararAmbiente_0 ; \
				python test_prep_amb.py config/CIPAL.cnf esperado_stdout_PrepararAmbiente_0 ; \
				echo ; \
				echo CORRIDA CON LA INSTALACION YA REALIZADA; \
				bash PrepararAmbiente.sh > real_stdout_PrepararAmbiente_1 ; \
				python test_prep_amb.py config/CIPAL.cnf esperado_stdout_PrepararAmbiente_1 ; \
				echo ----------------------")

preparar_ambiente()

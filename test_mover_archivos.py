#coding=utf-8

import os
import os.path
import sys

def test_movimiento_de_archivos(file_name, is_valid):
	'''Chequea que el archivo pasado por parámetro sea pasado al directorio
	correcto'''
	if is_valid.upper() == "TRUE":
		is_valid = True
	else:
		is_valid = False

	if is_valid:
		prefix = "aceptados/"
	else:
		prefix = "rechazados/"
	
	was_moved_to_correct_directory = os.path.isfile(prefix + file_name)
	was_moved_not_copied = not os.path.isfile("arribados/" + file_name)
	
	if was_moved_not_copied:
		print "EXITO: el archivo {} ya no se encuentra en arribados".format(file_name)
	else:
		print "ERROR: el archivo {} todavía se encuentra en arribados".format(file_name)
	if was_moved_to_correct_directory:
		print "EXITO: el archivo {} fue movido al directorio correspondiente".format(file_name)
	else:
		print "ERROR: el archivo {} no fue movido al directorio correspondiente".format(file_name)

test_movimiento_de_archivos(sys.argv[1], sys.argv[2])

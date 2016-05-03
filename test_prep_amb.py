#coding=utf-8

import os
import sys

def obtener_variables(input_file):
    '''Lee un archivo de configuración y devuelve un diccionario con las
    variables de entorno a setear'''
    with open(input_file) as config:
        env_vars = {}
        for line in config:
            parsed = line.rstrip("\n").split("=")
            env_vars[parsed[0]] = parsed[1]
        return env_vars

def test_todas_variables_seteadas(input_file):
    '''Chequea que todas las variables que figuran en el archivo de
    configuracion hayan sido seteadas'''
    env_vars = obtener_variables(input_file)
    messages = []
    c = 0
    for var in env_vars:
        m = "Variable {} está en ambiente: ".format(var)
        if var in os.environ:
            c += 1
            m += "OK"
        else:
            m += "ERROR"
        messages.append(m)
    if c != len(env_vars):
        print "ERROR: no todas las variables se encuentran en el ambiente"
        show_detail = raw_input("Desea imprimir el detalle? [* = No | Cualquier otra entrada = Si]") != "*"
        if show_detail:
            for line in messages:
                print line
    else:
        print "EXITO: todas las variables se encuentran en el ambiente"

def test_contenido_variables(input_file):
    '''Chequea que todas las variables hayan sido seteadas con el contenido 
    correcto'''
    env_vars = obtener_variables(input_file)
    messages = []
    c = 0
    for var in env_vars:
        m = "Variable {} seteada correctamente: ".format(var)
        if var in os.environ: 
            if env_vars[var] == os.environ[var]:
                c += 1
                m += "OK"
            else:
                m += "ERROR. Real: {}. Esperado: {}.".format(os.environ[var], env_vars[var])
        else:
            m += "ERROR. No se encuentra la variable"
        messages.append(m)
    if c != len(env_vars):
        print "ERROR: no todas las variables se encuentran seteadas correctamente"
        show_detail = raw_input("Desea imprimir el detalle? [* = No | Cualquier otra entrada = Si]") != "*"
        if show_detail:
            for line in messages:
                print line
    else:
        print "EXITO: todas las variables se encuentran seteadas correctamente"

def test_contenido_archivos(expected_file, out_file):
    '''Chequea que los contenidos de un archivo sean los esperados'''
    with open(out_file) as out, open(expected_file) as expected:
        e = "".join([line.rstrip("\n") for line in expected]).replace(" ","").upper()
        r = "".join([line.rstrip("\n") for line in out]).replace(" ","").upper()
        if e == r:
            print "EXITO: los archivos son iguales"
        else:
            print "ERROR: los archivos no son iguales."

def main():
    NOMBRE_ARCHIVO_LOG = "XXXXXXXXX"
    test_todas_variables_seteadas(sys.argv[1])
    test_contenido_variables(sys.argv[1])
    #print "Chequeo de salida estandar"
    #print "\t",
    #test_contenido_archivos(sys.argv[2], sys.argv[3])
    #print "Chequeo de archivo de log"
    #print "\t",
    #test_contenido_archivos(sys.argv[2], NOMBRE_ARCHIVO_LOG)

main()




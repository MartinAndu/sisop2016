################################################################################################################################################
	FIUBA - 75.08 - Sistemas Operativos - Primer Cuatrimestre 2016
	   GRUPO N° 2
			
	      	# Alfonso Oderigo, Diego		83969
	      	# Andújar, Martín			95099
		# Castro Pippo, Juan Manuel		93760
		# Moriello, Khalil Alejandro		96525
		# Savulsky, Sebastián Alejandro		93081
		# Sueiro, Ignacio Andrés		96817

################################################################################################################################################
									Descripción del Sistema
################################################################################################################################################
		
    
	El Sistema CIPAL realiza las adjudicaciones por sorteo y licitación para una empresa que vende unidades automotoras a través de un
	sistema de plan de ahorro. 
	Una vez recibidos los archivos con las ofertas, para realizar las adjudicaciones por sorteo genera un archivo de 168 entradas y valores
	aleatorios que indicarán el número asignado a cada participante. Para las licitaciones, valida los registros de los archivos recibidos y
	filtra las participaciones correctas (es decir, si la persona se encuentra en condiciones de participar, si realizó una oferta válida y
	su grupo no se encuentra cerrado) y, si no ha sido beneficiado por el sorteo, otorga la adjudicación al cliente que pase todas estas 
	verificaciones y haya realizado la mayor oferta.
	
################################################################################################################################################
							Pasos a seguir para correr el Sistema Operativo
################################################################################################################################################
 	
	1- Si no ha hecho previamente, se debe indicar la prioridad de booteo en la BIOS del equipo. Para realizarlo, es necesario reiniciar la
	PC, acceder a la BIOS (dependiendo del equipo puede solicitarse una tecla distinta para acceder al momento de volver a iniciarlo, pero 
	esta suele ser F2). Una vez allí, hay que indicar el orden de prioridades de booteo. Como se provee de una unidad de almacenamiento
	externa (pen-drive), seleccionar uno de los puertos USB disponibles y colocarlo al tope de la lista. Guardar la configuración y salir.
	
	2- Con el equipo apagado, se debe insertar la unidad de almacenamiento (pen-drive) booteable en el puerto USB previamente seleccionado.
	
	3- Luego de inicializar el sistema desde el pen-drive, por pantalla se debe seleccionar la utilización de la versión de prueba
	(“try Ubuntu”)
	
	4- Al realizar todos los pasos anteriores, se contará con el Sistema Operativo necesario y preparado para poder correr CIPAL.

################################################################################################################################################
								   Requisitos de instalación
################################################################################################################################################

	Contar con Perl versión 5 o superior.
		
################################################################################################################################################
						Pasos a seguir en la instalación y ejecución del programa CIPAL
################################################################################################################################################

	1- Insertar el dispositivo de almacenamiento con el contenido del sistema (pen-drive, cd, etc)

	2- Ubicarse en el directorio donde se desea ejecutar el instalador. 

	3- Copiar el archivo cipal.tar.gz en dicho directorio.

	4- Descomprimir el archivo cipal.tar.gz. haciendo Click Derecho -> ”Extraer aquí”.

	5. Para instalar el programa, se deberá ir a la ruta de esta carpeta base mediante la consola y ejecutar el instalador. Para abrir una
	terminal se deben presionar en simultáneo Ctrl + Alt + “T”. Una vez abierta la terminal, se ejecutarán los siguientes comandos:

		$ cd [ruta_programa]
		$ ./instalarCipal.sh

	6. Luego de esto, se habrá creado la carpeta “grupo02” en el directorio "home" del usuario, la cual es la base del programa.
	
	7. Si el instalador finalizó correctamente, se podrá ver que se crearon varias carpetas. Dirigirse a la carpeta definida para los 
	archivos ejecutables (por defecto "home/usuario/grupo02/binarios"):

	   	$ cd binarios

	8. Inicializar el programa mediante el siguiente comando:

		$ . ./PrepararAmbiente.sh

	   En este momento,se puede optar por ejecutar el demonio de recepción de ofertas o no.
	   Si se decide no ejecutarlo, puede hacerlo manualmente mediante el siguiente comando:

		$ ./LanzarProceso.sh RecibirOfertas

	9. Si el usuario quiere detener la ejecución de este demonio, deberá escribir:

		$ ./DetenerProceso.sh RecibirOfertas

################################################################################################################################################
							Generar consultas e informes	
################################################################################################################################################

	Luego de haber procesado los archivos, se pueden generar consultas e informes ejecutando el siguiente comando (siempre
	situado en la carpeta “/binarios/“:

		$ ./determinarGanadores.pl -*modo*

	Existen tres modos:
		- a: es el modo ayuda. Mostrará por pantalla la información necesaria para ejecutar y comprender el comportamiento del programa
		- *Sin parámetros*: es el modo interactivo. Permite realizar consultas
		- g: ejecuta el modo interactivo, pero además graba los resultados de las consultas en un archivo

################################################################################################################################################
							DetenerProceso	
################################################################################################################################################
        
	DetenerProceso sirve para detener un proceso que está corriendo. El funcionamiento es el siguiente: chequea que el comando a detener
	ingresado por el usuario exista en la carpeta binarios, luego verifica que el ambiente este inicializado y finalmente verifica que el
	programa a detener introducido realmente esté corriendo. Si todas esas hipótesis se verifican se detiene el proceso. Caso contrario
	el comando sale con un mensaje de error.

		$ ./DetenerProceso.sh "comando"
	
	"comando" representa el comando que se desea detener, sin extensión.

################################################################################################################################################
							LanzarProceso	
################################################################################################################################################
        
	LanzarProceso sirve para iniciar un proceso. El funcionamiento es el siguiente: chequea que el comando a iniciar
	ingresado por el usuario exista en la carpeta binarios, luego verifica que el ambiente este inicializado, graba la información en el log
	del sistema CIPAL y finalmente verifica que el programa a iniciar introducido no esté corriendo. Si todas esas hipótesis se verifican se
	detiene el proceso. Caso contrario el comando sale con un mensaje de error.

		$ ./LanzarProceso.sh "comando" ["comandoInvocador"]

	"comando" es el comando que se desea ejecutar, si se especifica solo este parametro, los resultados se muestran por pantalla.
	"comandoInvocador" si se especifica la salida la hace en el archivo de log, sin mostrar datos por pantalla. 
	Ambos comandos se escriben sin extensión.

################################################################################################################################################

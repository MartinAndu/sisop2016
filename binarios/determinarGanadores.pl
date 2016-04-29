#!/usr/bin/env perl

sub manejar_error {
	my $mensaje_error = shift;
	$mensaje_error .= "\n\t";
	die $mensaje_error;
}

sub validar_ambiente {
	@variables_ambiente = ('MAEDIR', 'PROCDIR', 'INFODIR', 'GRUPO', 'LOCKDIR');
	foreach $variable_ambiente (@variables_ambiente) {
		manejar_error "Error en inicializacion de ambiente: no esta definida la variable de entorno $variable_ambiente" 
			unless exists $ENV{$variable_ambiente};
		$configuracion{$variable_ambiente} = $ENV{$variable_ambiente};
	}
}

sub inicializar_proceso {
	my @path_proceso = split('/', $0);
	my $nombre_proceso = $path_proceso[$#path_proceso];
	$pid_filename = $ENV{LOCKDIR}.'/'.$nombre_proceso.'.pid';

	manejar_error "Error: ya hay otro proceso $nombre_proceso corriendo. Finalicelo antes de iniciar uno nuevo."
		if -e $pid_filename;

	open(PIDFILE, ">$pid_filename")
		or manejar_error "Error: no se pudo escribir el archivo de bloqueo $pid_filename";
	if (!print PIDFILE "$$\n") {
		# Necesito esto para poder cerrar el archivo antes de pasar el control a manejar_error
		close(PIDFILE);
		manejar_error "Error: no se pudo escribir el archivo de bloqueo $pid_filename";
	}
	close(PIDFILE);
}

END {
	unlink $pid_filename if -e $pid_filename;
}

sub buscar_archivos_sorteo {
	opendir(DIRECTORIO_SORTEOS, "$configuracion{'PROCDIR'}/sorteos")
		or manejar_error "Error: no se encuentra directorio de archivos de sorteos. Contacte al administrador para recuperar la instalacion del sistema";
	while(my $archivo_sorteo = readdir DIRECTORIO_SORTEOS) {
		push(@archivos_sorteo, $archivo_sorteo) unless $archivo_sorteo eq '.' or $archivo_sorteo eq '..';
	}
	closedir(DIRECTORIO_SORTEOS);
	return @archivos_sorteo;
}

sub settear_archivo_sorteo_default {
	my ($max_fecha_adj, $max_sorteo_id, $max_archivo);
	@archivos_sorteo_disponibles = &buscar_archivos_sorteo;
	if (!@archivos_sorteo_disponibles) {
		manejar_error "Error: no se encontraron sorteos. Genere el sorteo de la adjudicacion y vuelva a ejecutar el comando";
	}
	foreach $archivo (@archivos_sorteo_disponibles) {
		my ($sorteo_id, $fecha_adjudicacion) = split('_', (split('\.', $archivo))[0]);
		if ($fecha_adjudicacion > $max_fecha_adj or ($fecha_adjudicacion == $max_fecha_adj and $sorteo_id > $max_sorteo_id)) {
			$max_fecha_adj = $fecha_adjudicacion;
			$max_sorteo_id = $sorteo_id; 
			$max_archivo = $archivo;
		}
	}
	$fecha_adjudicacion_seleccionada = $max_fecha_adj;
	$sorteo_id_seleccionado = $max_sorteo_id;
	$archivo_sorteo_seleccionado = $max_archivo;
}

sub cargar_resultado_sorteo {
	open (SORTEO, "<$configuracion{'PROCDIR'}/sorteos/$archivo_sorteo_seleccionado")
		or manejar_error "Error: no se pudo abrir el archivo de sorteos $archivo_sorteo_seleccionado";
	while (<SORTEO>) {
		my ($nro_orden, $nro_sorteado) = split(';', $_);
		$resultado_sorteo[$nro_sorteado] = $nro_orden;
	}
	close SORTEO;
}

sub cargar_maestro_grupos {
	#open (GRUPOS, 
}

sub imprimir_resultado {
	my $resultado = shift(@_) . "\n";
	print $resultado;
	if ($grabar and !print SALIDA $resultado) {
		close SALIDA;
		manejar_error "Error: no se pudo escribir el archivo de salida";
	}
}

sub mostrar_menu {
	my $fecha_adjudicacion_formateada = substr($fecha_adjudicacion_seleccionada, 6, 2) . "/"
						. substr($fecha_adjudicacion_seleccionada, 4, 2) . "/"
						. substr($fecha_adjudicacion_seleccionada, 0, 4);
	print "CIPAL Reportes\n";
	print "--------------\n";
	print "\n";
	print "Fecha de Adjudicacion: $fecha_adjudicacion_formateada\n";
	print "Archivo de sorteo seleccionado: $archivo_sorteo_seleccionado\n";
	print "\n";
	print "Consultas:\n";
	print "A. Resultado general del sorteo\n";
	print "B. Ganadores por sorteo\n";
	print "C. Ganadores por licitacion\n";
	print "D. Resultados por grupo\n";
	print "\n";
	print "Otras opciones:\n";
	print "S. Cambiar archivo de sorteo / fecha de adjudicacion\n";
	print "X. Salir\n";
	print "\n";
	print "Su opcion: ";
}

sub resultado_general {
	cargar_resultado_sorteo unless defined(@resultado_sorteo);
	if ($grabar) {
		open (SALIDA, ">$configuracion{INFODIR}/$sorteo_id_seleccionado"."_$fecha_adjudicacion_seleccionada.txt")
			or manejar_error "Error: no se puede escribir el archivo de sorteos";
	}
	for ($i = 1; $i <= $#resultado_sorteo; $i++) {
		$nro_sorteo = sprintf("%03d", $i);
		$nro_orden = sprintf("%03d", $resultado_sorteo[$i]);
		imprimir_resultado "Nro. de Sorteo $nro_sorteo, le correspondio al numero de orden $nro_orden";
		if ($i % 23 == 22) {
			print "Presione ENTER para continuar";
			my $pausa = <STDIN>
		}
	}
	if ($grabar) {
		close SALIDA;
	}
}

sub ganadores_por_sorteo {}

&validar_ambiente;
&inicializar_proceso; 
&settear_archivo_sorteo_default;
while ($opcion ne 'X') {
	&mostrar_menu;
	$opcion = <STDIN>;
	chop($opcion);
	$opcion = uc($opcion);
	if ($opcion eq 'A') {resultado_general}; 
	if ($opcion eq 'B') {ganadores_por_sorteo};
	if ($opcion eq 'C') {ganadores_por_sorteo};
	if ($opcion eq 'D') {ganadores_por_sorteo};
	if ($opcion eq 'S') {ganadores_por_sorteo};
}
#&mostrar_menu;

#!/usr/bin/env perl

$archivo_padron_suscriptores = "temaL_padron.csv";
$archivo_maestro_grupos = "grupos.csv";

sub manejar_error {
	my $mensaje_error = shift;
	$mensaje_error .= "\n\t";
	&finalizar_proceso;
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

sub parsear_opciones_linea_comandos {
	foreach (@ARGV) {
		$ayuda = 1 if $_ eq '-a';
		$grabar = 1 if $_ eq '-g';
	}
}

sub inicializar_proceso {
	my @path_proceso = split('/', $0);
	my $nombre_proceso = $path_proceso[$#path_proceso];
	$pid_filename = $ENV{LOCKDIR}.'/'.$nombre_proceso.'.pid';

	if (-e $pid_filename) {
		print "Error: ya hay otro proceso $nombre_proceso corriendo. Finalicelo antes de iniciar uno nuevo.";
		exit(1);
	}

	open(PIDFILE, ">$pid_filename")
		or manejar_error "Error: no se pudo escribir el archivo de bloqueo $pid_filename";
	if (!print PIDFILE "$$\n") {
		# Necesito esto para poder cerrar el archivo antes de pasar el control a manejar_error
		close(PIDFILE);
		manejar_error "Error: no se pudo escribir el archivo de bloqueo $pid_filename";
	}
	close(PIDFILE);
}

sub finalizar_proceso {
	unlink $pid_filename if -e $pid_filename;
}

sub buscar_archivos_sorteo {
	@archivos_sorteo = ();
	opendir(DIRECTORIO_SORTEOS, "$configuracion{'PROCDIR'}/sorteos")
		or manejar_error "Error: no se encuentra directorio de archivos de sorteos. Contacte al administrador para recuperar la instalacion del sistema";
	while(my $archivo_sorteo = readdir DIRECTORIO_SORTEOS) {
		push(@archivos_sorteo, $archivo_sorteo) unless $archivo_sorteo eq '.' or $archivo_sorteo eq '..';
	}
	closedir(DIRECTORIO_SORTEOS);
	if (!@archivos_sorteo) {
		manejar_error "Error: no se encontraron sorteos. Genere el sorteo para la adjudicacion y vuelva a ejecutar el comando";
	}
	return @archivos_sorteo;
}

sub obtener_id_sorteo_y_fecha_por_nombre_archivo {
	my $archivo = shift;
	return split('_', (split('\.', $archivo))[0]);
}

sub settear_archivo_sorteo_default {
	my ($max_fecha_adj, $max_sorteo_id, $max_archivo);
	my @archivos_sorteo_disponibles = &buscar_archivos_sorteo;
	foreach my $archivo (@archivos_sorteo_disponibles) {
		my ($sorteo_id, $fecha_adjudicacion) = obtener_id_sorteo_y_fecha_por_nombre_archivo($archivo);
		if ($fecha_adjudicacion > $max_fecha_adj or ($fecha_adjudicacion == $max_fecha_adj and $sorteo_id > $max_sorteo_id)) {
			$max_fecha_adj = $fecha_adjudicacion;
			$max_sorteo_id = $sorteo_id; 
			$max_archivo = $archivo;
		}
	}
	$fecha_adjudicacion_seleccionada = $max_fecha_adj;
	$sorteo_id_seleccionado = $max_sorteo_id;
	$archivo_sorteo_seleccionado = $max_archivo;
	$fecha_adjudicacion_formateada = substr($fecha_adjudicacion_seleccionada, 6, 2) . "/"
						. substr($fecha_adjudicacion_seleccionada, 4, 2) . "/"
						. substr($fecha_adjudicacion_seleccionada, 0, 4);
}

sub cargar_resultado_sorteo {
	open (SORTEO, "<$configuracion{'PROCDIR'}/sorteos/$archivo_sorteo_seleccionado")
		or manejar_error "Error: no se pudo abrir el archivo de sorteos $archivo_sorteo_seleccionado";
	while (<SORTEO>) {
		chomp($_);
		my ($nro_orden, $nro_sorteado) = split(';', $_);
		$resultado_sorteo[$nro_sorteado] = $nro_orden;
		$ordenes_sorteo[$nro_orden] = $nro_sorteado;
	}
	close SORTEO;
}

sub cargar_maestro_grupos {
	open (GRUPOS, "<$configuracion{'MAEDIR'}/$archivo_maestro_grupos")
		or manejar_error "Error: no se pudo abrir el archivo maestro de grupos";
	while (<GRUPOS>) {
		my $cod_estado;
		chomp($_);
		my ($nro_grupo, $estado) = split (';', $_); 
		if ($estado eq 'ABIERTO') {$cod_estado = 1;}
		elsif ($estado eq 'NUEVO') {$cod_estado = 1;}
		elsif ($estado eq 'CERRADO') {$cod_estado = 0;}
		else {
			close GRUPOS;
			manejar_error "Error: estado de grupo inesperado en el siguiente registro del maestro de grupos: $_";
		}
		$maestro_grupos{$nro_grupo} = $cod_estado;
	}
	close GRUPOS;
}

sub cargar_padron_suscriptores {
	open (PADRON, "<$configuracion{'MAEDIR'}/$archivo_padron_suscriptores")
		or manejar_error "Error: no se pudo abrir el padron de suscriptores";
	while (<PADRON>) {
		chomp($_);
		my ($nro_grupo, $nro_orden) = split(';', $_);
		my $contrato_fusionado = $nro_grupo . $nro_orden;
		$padron_suscriptores{$contrato_fusionado} = $_;
	}
	close PADRON;
}

sub cargar_ofertas_licitacion {
	%ofertas_licitacion_por_grupo = ();
	if (-e "$configuracion{'PROCDIR'}/validas/$fecha_adjudicacion_seleccionada.txt") {
		open (OFERTAS, "<$configuracion{'PROCDIR'}/validas/$fecha_adjudicacion_seleccionada.txt")
			or manejar_error "Error: no se pudo abrir el archivo de ofertas procesadas $fecha_adjudicacion_seleccionada.txt";
		while (<OFERTAS>) {
			chomp($_);
			@registro_oferta = split(';', $_);
			$grupo_oferente = $registro_oferta[3];
			$nro_orden_oferente = $registro_oferta[4];
			$importe_oferta = $registro_oferta[5];
			$nombre_oferente = $registro_oferta[6];
			$detalle_oferta = join(';', ($nro_orden_oferente, $importe_oferta, $nombre_oferente));
			push @{ $ofertas_licitacion_por_grupo{$grupo_oferente} }, $detalle_oferta;
		}
		close OFERTAS;
	}
}

# Recibe por parametro un nro. de grupo. Devuelve el nro. de orden del ganador por sorteo de ese grupo,
# su nombre y su nro de sorteo asignado.
# Requiere que esten cargados el archivo de sorteos y el padron de suscriptores.
# Requiere que el grupo sea valido (exista en el maestro de grupos, no este cerrado y tenga al menos 
# un suscriptor participante (flag participa en 1 o 2)). De no cumplirse esta ultima condicion, se
# sale de la rutina sin devolver valores (devolviendo undef).
sub ganador_sorteo_en_grupo {
	my $nro_grupo = shift;
	for (my $nro_sorteo = 1; $nro_sorteo <= $#resultado_sorteo; $nro_sorteo++) {
		my $nro_orden = sprintf("%03d", $resultado_sorteo[$nro_sorteo]);
		my $contrato_fusionado = $nro_grupo . $nro_orden;
		next unless exists $padron_suscriptores{$contrato_fusionado};
		my @registro_suscriptor = split(';', $padron_suscriptores{$contrato_fusionado});
		my $flag_participa = $registro_suscriptor[5];
		next unless ($flag_participa eq '1' or $flag_participa eq '2');
		my $nombre = $registro_suscriptor[2];
		return ($nro_orden, $nombre, $nro_sorteo);
	}
	return;
}

# Recibe por parametro un nro. de grupo. Devuelve el nro. de orden del ganador por licitacion de
# ese grupo, su nombre, nro. de sorteo asignado y el importe de la oferta con la que gano.
# Si el grupo no tiene ofertas de licitacion, sale de la rutina sin devolver valores.
# Tiene todos los requerimientos de ganador_sorteo_en_grupo. Ademas requiere que se haya cargado
# el archivo de ofertas para la fecha de adjudicacion en curso.
# Asume que las ofertas recibidas estan "prevalidadas" (suscriptores con flag participa? en 1 o 2,
# importe valido, etc.)
sub ganador_licitacion_en_grupo {
	my $nro_grupo = shift;
	my $ganador_sorteo = (ganador_sorteo_en_grupo($nro_grupo))[0];
	# Si no hay ganador del sorteo es porque hay algun problema con el grupo (cerrado, sin
	# participantes) y se devuelve el resultado vacio;
	return unless $ganador_sorteo;
	my ($nro_orden_mejor_oferta, $nombre_mejor_oferta, $puesto_sorteo_mejor_oferta, $importe_mejor_oferta);
	my @ofertas_recibidas = @{ $ofertas_licitacion_por_grupo{$nro_grupo} };
	foreach my $detalle_oferta (@ofertas_recibidas) {
		my ($nro_orden_oferente, $importe, $nombre) = split(';', $detalle_oferta);
		next if $nro_orden_oferente eq $ganador_sorteo;
		$puesto_sorteo_oferente = $ordenes_sorteo[$nro_orden_oferente]; 
		if (($importe > $importe_mejor_oferta) or 
				($importe == $importe_mejor_oferta and $puesto_sorteo_oferente < $puesto_sorteo_mejor_oferta)) {
			$importe_mejor_oferta = $importe;
			$nombre_mejor_oferta = $nombre;
			$nro_orden_mejor_oferta = $nro_orden_oferente;
			$puesto_sorteo_mejor_oferta = $puesto_sorteo_oferente;
		}
	}
	return ($nro_orden_mejor_oferta, $nombre_mejor_oferta, $puesto_sorteo_mejor_oferta, $importe_mejor_oferta);
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

sub mostrar_opciones_ingreso_grupos {
	print "Especificar grupos para la consulta\n";
	print "\n";
	print "A. Un grupo\n";
	print "B. Lista de grupos\n";
	print "C. Intervalo de grupos\n";
	print "D. Todos los grupos\n";
	print "\n";
	print "Su opcion (D por defecto): ";
}

sub mostrar_opciones_seleccion_archivo_sorteo {
	print "Como desea seleccionar el archivo de sorteo?\n";
	print "\n";
	print "A. Ingresando manualmente el nombre del archivo\n";
	print "B. Seleccionandolo de una lista de archivos disponibles\n";
	print "\n";
	print "Su opcion (B por defecto): ";	
}

sub mostrar_ayuda {
	print "ESTE TEXTO SE DEBE REEMPLAZAR POR LA AYUDA DEL COMANDO!!!\n";
}

sub min_y_max_lista {
	my ($min, $max);
	foreach $elemento (@_) {
		($min = $elemento) if $elemento < $min;
		($max = $elemento) if $elemento > $max;
	}
	return ($min, $max);
}

sub formato_grupo_valido {
	my $grupo = shift;
	return ($grupo =~ /\d{4}/);
}

sub pedir_un_grupo {
	while (1) {
		print "Ingrese el nro. de grupo en 4 digitos (Ej. 7886): ";
		my $nro_grupo = <STDIN>;
		chomp($nro_grupo);
		if (!formato_grupo_valido($nro_grupo)) {
			print "Formato de grupo invalido. El nro. de grupo debe estar compuesto por 4 digitos\n";
		}
		elsif (!exists $maestro_grupos{$nro_grupo}) {
			print "El grupo ingresado no esta registrado en el archivo maestro de grupos\n";
		}
		else {
			return ($nro_grupo);
		}
	}
}

sub todos_los_grupos {
	return sort((keys %maestro_grupos));
}

sub validar_y_filtrar_lista_grupos {
	my @grupos_sin_validar = @_;
	my @grupos_validos;
	foreach my $grupo (@grupos_sin_validar) {
		if (!formato_grupo_valido($grupo)) {
			print "Se descarta $grupo porque no tiene un formato de 4 digitos\n";
		}
		elsif (!exists $maestro_grupos{$grupo}) {
			print "Se descarta $grupo porque no esta definido en el archivo maestro de grupos\n";
		}
		else {
			push @grupos_validos, $grupo;
		}
	}
	if (@grupos_validos) {
		print "La lista quedo conformada por los siguientes grupos:\n";
		print join(", ", @grupos_validos)."\n";
		print "Confirma? S/N (default [S]i): ";
		my $confirmacion = <STDIN>;
		chomp $confirmacion;
		if (uc($confirmacion) eq 'N') {
			@grupos_validos = ();
		}
	}
	else {
		print "La lista debe contener al menos un grupo para efectuar la consulta. Por favor, reingrese.\n";
	}
	return @grupos_validos; 

}

sub pedir_lista_grupos {
	my @grupos_validos;
	until (@grupos_validos) {
		print "Ingrese los grupos (4 digitos cada uno) separados por espacios y ENTER para finalizar: \n";
		my $lista_ingresada = <STDIN>;
		chomp($lista_ingresada);
		@grupos_sin_validar = split(' ', $lista_ingresada);
		@grupos_validos = validar_y_filtrar_lista_grupos(@grupos_sin_validar);
	}
	my %claves_unicas;
	my @grupos_sin_duplicados;
	foreach my $grupo (@grupos_validos) {
		next if exists $claves_unicas{$grupo};
		$claves_unicas{$grupo} = 1;
		push @grupos_sin_duplicados, $grupo;
	}
	@grupos_sin_duplicados = sort(@grupos_sin_duplicados);
	return @grupos_sin_duplicados;
}

sub pedir_rango_grupos {
	my @grupos_validos;
	until (@grupos_validos) {
		my ($grupo_desde_rango, $grupo_hasta_rango);
		while (1) {
			print "Ingrese el grupo 'Desde' del rango (4 digitos): ";
			$grupo_desde_rango = <STDIN>;
			chomp($grupo_desde_rango);
			last if formato_grupo_valido($grupo_desde_rango);
			print "Formato de grupo invalido. El nro. de grupo debe estar compuesto por 4 digitos\n";
		}
		while (1) {
			print "Ingrese el grupo 'Hasta' del rango (4 digitos): ";
			$grupo_hasta_rango = <STDIN>;
			chomp($grupo_hasta_rango);
			last if formato_grupo_valido($grupo_hasta_rango);
			print "Formato de grupo invalido. El nro. de grupo debe estar compuesto por 4 digitos\n";
		}
		@grupos_validos = validar_y_filtrar_lista_grupos($grupo_desde_rango..$grupo_hasta_rango);
	}
	return @grupos_validos;
}

sub pedir_grupos {
	&mostrar_opciones_ingreso_grupos;
	my @lista_grupos;
	my $opcion = <STDIN>;
	chomp($opcion);
	$opcion = uc($opcion);
	if ($opcion eq 'A') {@lista_grupos = pedir_un_grupo;}
	elsif ($opcion eq 'B') {@lista_grupos = pedir_lista_grupos;}
	elsif ($opcion eq 'C') {@lista_grupos = pedir_rango_grupos;}
	else {@lista_grupos = todos_los_grupos;}
	return @lista_grupos;
}

sub comparar_por_fecha_despues_por_id_sorteo {
	my ($id_sorteo_a, $fecha_a) = split("_", $a);
	my ($id_sorteo_b, $fecha_b) = split("_", $b);
	$fecha_a cmp $fecha_b or $id_sorteo_a <=> $id_sorteo_b;
}

sub seleccionar_archivo_desde_lista {
	my @archivos_sorteo_disponibles = 
			sort comparar_por_fecha_despues_por_id_sorteo(&buscar_archivos_sorteo);
	print "Archivos Disponibles:\n";
	for (my $i = 0; $i <= $#archivos_sorteo_disponibles; $i++) {
		print (($i + 1) . ") " . $archivos_sorteo_disponibles[$i] . "\n");
	}
	print "\nSu opcion: ";
	my $opcion = <STDIN>;
	chomp($opcion);
	while ($opcion !~ /\d+/ or $opcion < 1 or $opcion > ($#archivos_sorteo_disponibles + 1)) {
		print "Debe ingresar un nro. entre 1 y " . ($#archivos_sorteo_disponibles + 1) . ". Reintente: ";
		$opcion = <STDIN>;
		chomp($opcion);
	}
	$archivo_sorteo_seleccionado = $archivos_sorteo_disponibles[$opcion - 1];
	($sorteo_id_seleccionado, $fecha_adjudicacion_seleccionada) =
			obtener_id_sorteo_y_fecha_por_nombre_archivo($archivo_sorteo_seleccionado);
	cargar_resultado_sorteo;
}

sub seleccionar_archivo_por_nombre {
	my $nombre_archivo;
	while (1) {
		print "Ingrese nombre del archivo de sorteo (formato <id_sorteo>_<fecha_adjudicacion>.txt): \n";
		$nombre_archivo = <STDIN>;
		chomp($nombre_archivo);
		last if $nombre_archivo and -e "$configuracion{'PROCDIR'}/sorteos/$nombre_archivo";
		print "No se encontro un archivo de sorteos con el nombre indicado. Por favor vuelva a intentar.\n"
	}
	$archivo_sorteo_seleccionado = $nombre_archivo;
	($sorteo_id_seleccionado, $fecha_adjudicacion_seleccionada) =
			obtener_id_sorteo_y_fecha_por_nombre_archivo($archivo_sorteo_seleccionado);
	cargar_resultado_sorteo;
}

sub seleccionar_archivo_sorteo {
	&mostrar_opciones_seleccion_archivo_sorteo;
	my $opcion = <STDIN>;
	chomp($opcion);
	$opcion = uc($opcion);
	if ($opcion eq 'A')	{seleccionar_archivo_por_nombre;}
	else {seleccionar_archivo_desde_lista;}
	$fecha_adjudicacion_formateada = substr($fecha_adjudicacion_seleccionada, 6, 2) . "/"
					. substr($fecha_adjudicacion_seleccionada, 4, 2) . "/"
					. substr($fecha_adjudicacion_seleccionada, 0, 4);
}

sub resultado_general {
	cargar_resultado_sorteo unless @resultado_sorteo;
	if ($grabar) {
		open (SALIDA, ">$configuracion{INFODIR}/$sorteo_id_seleccionado"."_$fecha_adjudicacion_seleccionada.txt")
			or manejar_error "Error: no se puede escribir el archivo de sorteos";
	}
	for (my $i = 1; $i <= $#resultado_sorteo; $i++) {
		$nro_sorteo = sprintf("%03d", $i);
		$nro_orden = sprintf("%03d", $resultado_sorteo[$i]);
		imprimir_resultado "Nro. de Sorteo $nro_sorteo, le correspondio al numero de orden $nro_orden";
		if ($i % 24 == 22) {
			print "Presione ENTER para continuar";
			my $pausa = <STDIN>
		}
	}
	if ($grabar) {
		close SALIDA;
	}
}

sub ganadores_por_sorteo {
	cargar_resultado_sorteo unless @resultado_sorteo;
	my @grupos = pedir_grupos;
	if ($grabar) {
		my $filename_ganadores_sorteo = $configuracion{INFODIR} . "/sorteo_" . $sorteo_id_seleccionado 
				. "_Grd" . $grupos[0] . "-Grh" . $grupos[$#grupos] . "_" . $fecha_adjudicacion_seleccionada . ".txt";
		open (SALIDA, ">$filename_ganadores_sorteo")
			or manejar_error "Error: no se puede escribir el archivo de ganadores por sorteo";
		my $grupo_desde = $grupos[0];
		my $grupo_hasta = $grupos[$#grupos];
	}
	imprimir_resultado "Ganadores del Sorteo $sorteo_id_seleccionado de fecha $fecha_adjudicacion_formateada";
	foreach my $grupo (@grupos) {
		if (!$maestro_grupos{$grupo}) {
			imprimir_resultado "El grupo $grupo esta cerrado";
			next;
		}
		my ($orden, $nombre, $nro_sorteado) = ganador_sorteo_en_grupo($grupo);
		if ($orden and $nombre and $nro_sorteado) {
			imprimir_resultado "Ganador por sorteo del grupo $grupo: Nro de Orden $orden, $nombre (Nro. de sorteo $nro_sorteado)";
		}
		else {
			imprimir_resultado "El grupo $grupo no tiene participantes del sorteo";
		}
	}
	if ($grabar) {
		close SALIDA;
	}
}

sub ganadores_por_licitacion {
	cargar_resultado_sorteo unless @resultado_sorteo;
	cargar_ofertas_licitacion unless %ofertas_licitacion_por_grupo;
	my @grupos = pedir_grupos;
	if ($grabar) {
		my $filename_ganadores_licitacion = $configuracion{INFODIR} . "/licitacion_" . $sorteo_id_seleccionado 
				. "_Grd" . $grupos[0] . "-Grh" . $grupos[$#grupos] . "_" . $fecha_adjudicacion_seleccionada . ".txt";
		open (SALIDA, ">$filename_ganadores_licitacion")
			or manejar_error "Error: no se puede escribir el archivo de ganadores por licitacion";
	}
	imprimir_resultado "Ganadores por Licitacion $sorteo_id_seleccionado de fecha $fecha_adjudicacion_formateada";
	foreach my $grupo (@grupos) {
		if (!$maestro_grupos{$grupo}) {
			imprimir_resultado "El grupo $grupo esta cerrado";
			next;
		}
		my ($orden, $nombre, $nro_sorteado, $importe) = ganador_licitacion_en_grupo($grupo);
		if ($orden and $nombre and $nro_sorteado and $importe) {
			imprimir_resultado "Ganador por licitacion del grupo $grupo: Nro de Orden $orden, $nombre con \$$importe (Nro. de sorteo $nro_sorteado)";
		}
		else {
			imprimir_resultado "El grupo $grupo no tiene ganadores por licitacion";
		}
	}
	if ($grabar) {
		close SALIDA;
	}
}

sub resultados_por_grupo {
	cargar_resultado_sorteo unless @resultado_sorteo;
	cargar_ofertas_licitacion unless %ofertas_licitacion_por_grupo;
	my @grupos = pedir_grupos;
	foreach my $grupo (@grupos) {
		if ($grabar) {
			my $filename_ganadores_grupo = $configuracion{INFODIR} . "/" . $sorteo_id_seleccionado 
					. "_Grupo" . $grupo . "_" . $fecha_adjudicacion_seleccionada . ".txt";
			open (SALIDA, ">$filename_ganadores_grupo")
				or manejar_error "Error: no se puede escribir el archivo de ganadores por licitacion";
		}
		imprimir_resultado "Ganadores por Grupo en el acto de adjudicación de fecha $fecha_adjudicacion_formateada,"
				. " Sorteo: $sorteo_id_seleccionado";
		if (!$maestro_grupos{$grupo}) {
			imprimir_resultado "El grupo $grupo esta cerrado";
			next;
		}
		my ($orden_sorteo, $nombre_sorteo) = ganador_sorteo_en_grupo($grupo);
		my ($orden_licitacion, $nombre_licitacion) = ganador_licitacion_en_grupo($grupo);
		imprimir_resultado "$grupo-$orden_sorteo S $nombre_sorteo" if $orden_sorteo and $nombre_sorteo;
		imprimir_resultado "$grupo-$orden_licitacion L $nombre_licitacion" if $orden_licitacion and $nombre_licitacion;
		if ($grabar) {
			close SALIDA;
		}
	}
}

&parsear_opciones_linea_comandos;
if ($ayuda) {
	mostrar_ayuda;
	exit(0);
}
&validar_ambiente;
&inicializar_proceso; 
&settear_archivo_sorteo_default;
&cargar_maestro_grupos;
&cargar_padron_suscriptores;
while ($opcion ne 'X') {
	&mostrar_menu;
	$opcion = <STDIN>;
	chomp($opcion);
	$opcion = uc($opcion);
	if ($opcion eq 'A') {resultado_general}; 
	if ($opcion eq 'B') {ganadores_por_sorteo};
	if ($opcion eq 'C') {ganadores_por_licitacion};
	if ($opcion eq 'D') {resultados_por_grupo};
	if ($opcion eq 'S') {seleccionar_archivo_sorteo};
}
&finalizar_proceso;

#!/usr/bin/perl
# ******************************************************************
# Universidad de Buenos Aires            *
# Facultad de Ingenieria             *
#                  *
# 75.08 Sistemas Operativos            *
# Catedra Ing. Osvaldo Clua            *
#                  *
# Autores: Grupo 8               *
#                  *
# ******************************************************************

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Text::Glob qw(match_glob);

# Definiciones

#
my $ANIO = '2016';
my $COMANDO;

my $DIRMAE;
my $DIRINFO;
my $DIRPROC;
my $GRUPO;
my $CENTROS;
my $ACTIVIDADES;
my $ACT_CENTROS;
my $SANCIONADO;
my $ACEPTADO;
my $OUTDIR;

# El separador a usar en los archivos de salida
my $SEP = ';';

# opción ct, si es true ordena primero por trimestre y luego por código de centro
my $porTrimestre = '';

# Lista de actividades a filtrar por
my @filtroActividades;

my $WRITE = '';

# listado Presupuesto Sancionado
sub listadoPS;

# listado del Presupuesto Ejecutado
sub listadoPE;

# listado de Control del Presupuesto Ejecutado
sub listadoCPE;


sub verificarEntorno {
  # TODO: Para el primer listado no necesito el DIRPROC
  foreach my $key (('DIRMAE', 'DIRINFO', 'DIRPROC', 'GRUPO')) {
    if (!exists $ENV{$key}) {
      die "El entorno no está inicializado! Falta definir la variable $key\n";
    }
  }
}

sub procesarParametros {
  $COMANDO = shift @ARGV || '';

  if ( !grep( /^$COMANDO$/, ('sanc', 'ejec', 'cont') ) ) {
    return 0;
  }

  GetOptions (
    "tc" => \$porTrimestre,
    "anio:s" => \$ANIO,
    "write" => \$WRITE,
    "actividad:s" => \@filtroActividades,
  );
  return 1;
}


#*******************************************************************
#
# Mensaje de ayuda
#
#*******************************************************************
sub mostrarAyuda {
  (my $helpMessage = q{Uso:
    listep.pl [comando] [--write|-w] [--tc] [--year|-y]

    Comando puede ser:
        - sanc: Para listado del Presupuesto Sancionado
        - ejec: Para listado del Presupuesto Ejecutado
        - cont: Para listado de Control del Presupuesto Ejecutado

    Argumentos para todos los comandos:
      -w, --write  Si se especifica este flag, el resultado se va a escribir en un archivo
                   de salida (además de mostrarse por pantalla).
      -a, --anio   Este parametro se le puede especificar a los comandos sanc y ejec. Es el
                   año, para el cual se desea calcular el listado. 2016 por defecto.

    Comando sanc:
      El comando sanc devuelve un listado con el presupuesto total para un año.
      El nombre para el archivo, si se especifica la variable -w se genera de la
      siguiente manera: sanc_ORDEN_AÑO.csv, donde ORDEN puede ser tc o ct (
      dependiendo de si se especifica el parametro --tc), y AÑO es el año para el
      cual se genera el listado.

      Estos son sus parametros:

      --tc         El comando sanc devuelve un listado por trimestre y luego por código del
                   centro. Para invertir el orden se le tiene que especificar esta opción.

    Comando ejec:
      Devuelve el presupuesto ejecutado para un año presupuestario especificado.

      Parametros:
      -ac, --actividad  La actividad o las actividades, para las cuales se va a
                        generar el listado. Se pueden especificar multiples
                        actividades de la siguiente manera:

                        listep.pl ejec -ac "act 1" -ac "act 2"

  })  =~ s/^ {4}//mg;

  print $helpMessage;
}


#*******************************************************************
#
# Rutina main
#
#*******************************************************************
sub main() {
  verificarEntorno;
  if (!procesarParametros) {
    return mostrarAyuda;
  }

  $DIRMAE = $ENV{DIRMAE};
  $DIRINFO = $ENV{DIRINFO};
  $DIRPROC = $ENV{DIRPROC};
  $GRUPO = $ENV{GRUPO};

  $CENTROS = $GRUPO . '/' .$DIRMAE . '/centros.csv';
  $ACTIVIDADES = $GRUPO . '/' . $DIRMAE . '/actividades.csv';
  $ACT_CENTROS = $GRUPO . '/' . $DIRMAE . '/tabla-AxC.csv';
  $SANCIONADO = $GRUPO . '/' . $DIRMAE . '/sancionado-' . $ANIO . '.csv';
  $OUTDIR = $GRUPO . '/' . $DIRINFO;

  $ACEPTADO = $GRUPO . '/' . $DIRPROC . '/aceptado-' . $ANIO;

  if ($COMANDO eq 'sanc') {
    listadoPS();
  } elsif ($COMANDO eq 'ejec') {
    listadoPE();
  } elsif ($COMANDO eq 'cont') {
    listadoCPE();
  }
}


main();

# Toma por parametro el nombre del archivo, la extensión y el contenido
# Escribe la salida en el archivo. Si este ya existe, lo escribe a un archivo
# que de nombre tendra nombre_del_archivo.N.extensión
# El archivo se escribe en el directorio, definido en la variable $DIRINFO
sub writeOutput {
  my ($name, $extension, $content) = @_;
  my $filename = "$OUTDIR/$name.$extension";
  my $counter = 0;
  while (-e $filename) {
    $filename = "$OUTDIR/$name.$counter.$extension";
    $counter++;
  }
  open(my $fh, '>', $filename) or die "ERROR: No puedo abrir el archivo $filename -> $!\n";
  print $fh $content;
  close $fh;
}

# Esta subrutina toma los siguientes parametros:
# hash, archivo, subrutina para clave, subrutina para valor
# Lee un archivo y llena el hash que se le pasó por parametro usando las
# funciones para obtener clave y valor (se les pasa el listado de variables)
sub fillHash {
  my ($centrosHashRef, $filename, $getKey, $getValue) = @_;

  open(my $fh, "<$filename") || die "ERROR: No puedo abrir el archivo $filename -> $!\n";

  # Ignoro el header
  my $header = <$fh>;
  while (my $line = <$fh>) {
    chomp $line;
    my @fields = split(/;/, $line);
    $centrosHashRef->{&{$getKey}(@fields)} = &{$getValue}(@fields);
  }

  close($fh);
}


# Esta subrutina convierte las comas de una string a puntos, es necesario
# para tratar números con punto flotante correctamente, ya que en los csvs
# aparecen con comas.
sub commaToDot {
  my($value) = @_;
  $value =~ s/\,/./g;
  return $value;
}

# Viceversa de la anterior
sub dotToComma {
  my($value) = @_;
  $value = sprintf("%.2f", $value);
  $value =~ s/\./,/g;
  return $value;
}


# Lee el archivo de centros y llena el diccionario centrosHash
# con id_centro => nombre del centro
sub readCentros {
  fillHash($_[0], $CENTROS, (sub { return $_[0] } ),
                            (sub { return $_[1] } ) );
}


# Lee el archivo de centros y llena el diccionario axcHash
# con id_actividad id_centro concatenados como clave, de esta forma es
# sencillo luego verificar la existencia de esa combinación.
sub readAxC {
  fillHash($_[0], $ACT_CENTROS,
            (sub { return $_[0].$_[1] } ),
            (sub { return () } ) );
}


# Lee el archivo de sancionados y llena el hash pasado por referencia
# id_centro y trimestre concatenados como clave, y la suma de los saldos
# como valor
sub readSancionado {
  fillHash($_[0], $SANCIONADO,
            (sub { return $_[0].$_[1] } ),
            (sub { return commaToDot($_[2]) + commaToDot($_[3]) } ) );
}

#*******************************************************************
#
# Rutina de listado de Presupuesto Sancionado
#
#*******************************************************************
sub listadoPS {
  my %centrosHash;

  readCentros(\%centrosHash);

  open(my $sancionadoFile, "<$SANCIONADO") || die "ERROR: No puedo abrir el archivo $SANCIONADO -> $!\n";

  my $output = "A\ño presupuestario $ANIO" . $SEP . "Total Sancionado\n";
  # Ignoro el header
  my $header = <$sancionadoFile>;
  my %data;

  # En este while voy a llenar un hash de arrays de la siguiente forma
  # En el caso de la opción ct (porTrimestre = true):
  #   { Direccion General Alfa => [ [Primer Trimestre 2016, 121], [Segundo Trimestre 2016, 141], etc ]}
  # En el caso de la opción tc (porTrimestre = false):
  #   { Primer Trimestre 2016 => [ [Unidad Ministro, 2000], [Direccion General Alfa, 121], etc ]}
  while (my $line = <$sancionadoFile>) {
    my @fields = split(/;/, $line);
    my $centro = $centrosHash{$fields[0]};
    my $firstKey; my $secondKey;
    if ($porTrimestre) {
      $firstKey = $centro; $secondKey = $fields[1];
    } else {
      $firstKey = $fields[1]; $secondKey = $centro;
    }

    if (!exists $data{$firstKey}) {
      $data{$firstKey} = [];
    }
    my $value = commaToDot($fields[2]) + commaToDot($fields[3]);
    push(@{$data{$firstKey}}, [$secondKey, $value]);
  }

  my $total = 0;

  # Uso un array de claves para iterar sobre el hash en el orden correcto
  my @keys;
  if ($porTrimestre) {
    @keys = sort keys %data;
  } else {
    my @trimestres = ("Primer", "Segundo", "Tercer", "Cuarto");
    @keys = map {$_ . " Trimestre " . $ANIO} @trimestres;
  }

  foreach my $key (@keys) {
    my $subtotal = 0;
    foreach my $items ( @{$data{$key}} ) {
      my $value = @$items[1];
      $subtotal += $value;
      $output .= "@$items[0]" . $SEP . dotToComma($value) . "\n";
    }
    $total += $subtotal;
    $output .= "$key" . $SEP . dotToComma($subtotal) . "\n";
  }
  $output .= "Total Anual" . $SEP . dotToComma($total) . "\n";

  close($sancionadoFile);

  print $output;
  if ($WRITE) {
    my $filename = "sanc_" . (($porTrimestre) ? "tc" : "ct") . "_$ANIO";
    writeOutput($filename, 'csv', $output);
  }


}



#*******************************************************************
#
# Rutina de listado del Presupuesto Ejecutado
# Necesito archivos: AxC, los aceptados de un año
#
#*******************************************************************
sub listadoPE {
  my %axcHash;

  # Leer la tabla AxC
  readAxC(\%axcHash);

  my $output = join($SEP, ('Fecha','Centro','Nom Cen','cod Act','Actividad',
                           'Trimestre','Gasto','Provincia','Control')) . "\n";

  open(my $aceptadoFile, "<$ACEPTADO") || die "ERROR: No puedo abrir el archivo $ACEPTADO -> $!\n";

  my $total = 0;
  while (my $line = <$aceptadoFile>) {
    chomp($line);
    # El archivo de aceptados tiene el ste formato:
    # 0: id, 1: fecha, 2: id_centro, 3: act, 4: trimestre,
    # 5: gasto, 6: archivo, 7: id_act, 8: prov, 9: centro
    my @fields = split(/;/, $line);

    # Verifico si el filtro está definido y la actividad está entre los valores
    # a filtrar
    if ( @filtroActividades && !grep(/^$fields[3]$/, @filtroActividades) ) {
      next;
    }

    # La salida debe ser: fecha, id_centro, centro, id_act, act,
    # trimestre, gasto, provincia, control
    my @outFields = ($fields[1], $fields[2], $fields[9], $fields[7],
                     $fields[3], $fields[4], $fields[5], $fields[8]);
    $output .= join($SEP, @outFields);

    # Verifico si en el diccionario de AxC aparece id_actividad y id_centro como clave
    if (! exists $axcHash{$fields[7].$fields[2]}) {
      $output .= $SEP . "gasto fuera de planificación\n"
    } else {
      $output .= "$SEP\n";
    }

    $total += commaToDot($fields[5]);
  }

  $output .= $SEP x 5 . "Total Credito Fiscal$SEP" . dotToComma($total) . "$SEP";
  print $output;

  if ($WRITE) {
    writeOutput("ejec_$ANIO", 'csv', $output);
  }

  close($aceptadoFile);
}


#*******************************************************************
#
# Rutina de listado de Control del Presupuesto Ejecutado
# Necesito archivos: AxC, los sancionados y los aceptados de un año
#
#*******************************************************************
sub listadoCPE {
  my %axcHash;
  readAxC(\%axcHash);

  my %sancionadoHash;
  readSancionado(\%sancionadoHash);

  # my %sancionadoHash;
  # readSancionado(\%sancionadoHash);

  my $output = join($SEP, ('ID', 'FECHA MOV','CENTRO','ACTIVIDAD','TRIMESTRE','IMPORTE',
                           'SALDO por TRIMESTRE','CONTROL','SALDO ACUMULADO')) . "\n";

  open(my $aceptadoFile, "<$ACEPTADO") || die "ERROR: No puedo abrir el archivo $ACEPTADO -> $!\n";

  my @lines;
  while (my $line = <$aceptadoFile>) {
    chomp($line);
    my @fields = split(/;/, $line);

    push(@lines, [$fields[0], $fields[1], $fields[2], $fields[9], $fields[4], $fields[5]]);

  }

  @lines = sort { ($a->[2] cmp $b->[2]) or ($a->[1] cmp $b->[1]) } @lines;

  # la combinación centro-trimestre actual
  my $currentKey = '';
  my $totalTrimestre = 0;
  my $total = 0;
  foreach my $line (@lines) {
    my @fields = @{$line};
    my $key = $fields[2].$fields[4];

    if ($key ne $currentKey) {
      # Hay que agregar la linea del presupuesto trimestral sancionado

      $totalTrimestre = commaToDot($sancionadoHash{$key});
      $total += $totalTrimestre;
      # TODO: agregar fecha del archivo trimestres
      $output .= join($SEP, ('(++)', 'fecha', $fields[2], '0', $fields[4],
                             dotToComma($totalTrimestre), '', dotToComma($total)));
      $output .= "\n";
      $currentKey = $key;
    }

    my $importe = commaToDot($fields[5]);
    $totalTrimestre -= $importe;
    $total -= $importe;
    push(@fields, (dotToComma($totalTrimestre), '', dotToComma($total)));
    $output .= join($SEP, @fields) . "\n";
  }

  chomp($output);
  $output .= ' (*)';

  print $output;
  # if (match_glob("foo.*", "foo.bar")) {
  #   print "matcheó!";
  # }
}

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

# Definiciones

#
my $DIRMAE;
my $DIRINFO;
my $DIRPROC;
my $GRUPO;
my $CENTROS;
my $ANIO = '2015';
my $SANCIONADO;
my $COMANDO;

# El separador a usar en los archivos de salida
my $SEP = ';';

# opción ct, si es true ordena primero por trimestre y luego por código de centro
my $porTrimestre = '';

my $WRITE = '';

# listado Presupuesto Sancionado
sub listadoPS;

# listado del Presupuesto Ejecutado
sub listadoPE;

# listado de Control del Presupuesto Ejecutado
sub listadoCPE;


sub verificarEntorno {
  # TODO: Para el primer listado no necesito el DIRPROC
  foreach my $key (('DIRMAE', 'DIRINFO', 'DIRPROC')) {
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
      --write, -w  Si se especifica este flag, el resultado se va a escribir en un archivo
                   de salida (además de mostrarse por pantalla).

    Comando sanc:
      El comando sanc devuelve un listado con el presupuesto total para un año.
      El nombre para el archivo, si se especifica la variable -w se genera de la
      siguiente manera: sanc_ORDEN_AÑO.csv, donde ORDEN puede ser tc o ct (
      dependiendo de si se especifica el parametro --tc), y AÑO es el año para el
      cual se genera el listado.

      Estos son sus parametros:

      --tc         El comando sanc devuelve un listado por trimestre y luego por código del
                   centro. Para invertir el orden se le tiene que especificar esta opción.
      -a, --anio   El año, para el cual se desea el listado calcular el listado. 2015 por
                   defecto.
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
  # Comento al grupo durante el desarrollo
  # $GRUPO = $ENV{GRUPO};
  # $ANIO = '2015';
  $CENTROS = $DIRMAE . '/centros.csv';
  # $CENTROS = $GRUPO . '/' . $CENTROS
  $SANCIONADO = $DIRMAE . '/sancionado-' . $ANIO . '.csv';
  # $SANCIONADO = $GRUPO . '/' . $SANCIONADO
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
  my $filename = "$DIRINFO/$name.$extension";
  my $counter = 0;
  while (-e $filename) {
    $filename = "$DIRINFO/$name.$counter.$extension";
    $counter++;
  }
  open(my $fh, '>', $filename) or die "ERROR: No puedo abrir el archivo $filename -> $!\n";
  print $fh $content;
  close $fh;
}


# Lee el archivo de centros y llena el diccionario centrosHash
# con id_centro => nombre del centro
sub readCentros {
  my $centrosHashRef = shift;

  open(my $centrosFile, "<$CENTROS") || die "ERROR: No puedo abrir el archivo $CENTROS -> $!\n";

  # Ignoro el header
  my $header = <$centrosFile>;
  while (my $line = <$centrosFile>) {
    chomp $line;
    my @fields = split(/;/, $line);
    $centrosHashRef->{$fields[0]} = $fields[1];
  }

  close($centrosFile);
}


# Esta subrutina convierte las comas de una string a puntos, es necesario
# para tratar números con punto flotante correctamente, ya que en los csvs
# aparecen con comas.
sub commaToDot {
  my($value) = @_;
  $value =~ s/\,/./g;
  return $value;
}

sub dotToComma {
  my($value) = @_;
  $value = sprintf("%.2f", $value);
  $value =~ s/\./,/g;
  return $value;
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


# listado del Presupuesto Ejecutado
# Necesito archivos: AxC, los ejecutados de un año
sub listadoPE {
  print "ListadoPE!\n"

  # Leer la tabla AxC

  my @ejecutados = glob("$DIRINFO/ejecutado_$ANIO_*.csv");
  my @lineas;
  my $output = join($SEP, ('Fecha','Centro','Nom Cen','cod Act','Actividad',
                           'Trimestre','Gasto','Provincia','Control'));
  foreach my $file (@ejecutados) {
      open my $fh, '<', $file;
      while (my $line = <$centrosFile>) {
        chomp $line;
        my @fields = split(/;/, $line);
        # if cumple con los filtros

        push(@lineas, @fields);
      }
  }

}


# listado de Control del Presupuesto Ejecutado
sub listadoCPE {
  print "ListadoCPE!\n"
}

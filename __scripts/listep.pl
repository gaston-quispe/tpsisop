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
my $GRUPO;
my $CENTROS;
my $ANIO;
my $SANCIONADO;
my $COMANDO;
# opción ct, si es true ordena primero por trimestre y luego por código de centro
my $porTrimestre;

# listado Presupuesto Sancionado
sub listadoPS;

# listado del Presupuesto Ejecutado
sub listadoPE;

# listado de Control del Presupuesto Ejecutado
sub listadoCPE;


sub verificarEntorno {
  if (!exists $ENV{DIRMAE}) {
    die "El entorno no está inicializado!";
  }
}

sub procesarParametros {
  $COMANDO = shift @ARGV || '';

  if ( !grep( /^$COMANDO$/, ('sanc', 'ejec', 'cont') ) ) {
    return 0;
  }

  GetOptions (
    "tc" => \$porTrimestre
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
    listep.pl [comando] [--tc]

    Comando puede ser:
        - sanc: Para listado del Presupuesto Sancionado
        - ejec: Para listado del Presupuesto Ejecutado
        - cont: Para listado de Control del Presupuesto Ejecutado

    --tc: El comando sanc devuelve un listado por trimestre y luego por código del
          centro. Para invertir el orden se le tiene que especificar esta opción.
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
  $GRUPO = $ENV{GRUPO};
  $ANIO = '2015';
  $CENTROS = $GRUPO . '/' . $DIRMAE . '/centros.csv';
  $SANCIONADO = $GRUPO . '/' . $DIRMAE . '/sancionado-' . $ANIO . '.csv';
  if ($COMANDO eq 'sanc') {
    listadoPS();
  } elsif ($COMANDO eq 'ejec') {
    listadoPE();
  } elsif ($COMANDO eq 'cont') {
    listadoCPE();
  }
}

main();


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

  print "A\ño presupuestario $ANIO;Total Sancionado\n";
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
      print "@$items[0];" . dotToComma($value) . "\n";
    }
    $total += $subtotal;
    print "$key;" . dotToComma($subtotal) . "\n";
  }
  print "Total Anual;" . dotToComma($total) . "\n";

  close($sancionadoFile);
}


# listado del Presupuesto Ejecutado
sub listadoPE {
  print "ListadoPE!\n"
}


# listado de Control del Presupuesto Ejecutado
sub listadoCPE {
  print "ListadoCPE!\n"
}

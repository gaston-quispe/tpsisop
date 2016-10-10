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

# Definiciones

#
my $dirmae;
my $centros;
my $anio;
my $sancionado;
# opción ct, si es true ordena primero por trimestre y luego por código de centro
my $porTrimestre;

# listado Presupuesto Sancionado
sub listadoPS;

# listado del Presupuesto Ejecutado
sub listadoPE();

# listado de Control del Presupuesto Ejecutado
sub listadoCPE();


sub main() {
  print "hola\n";
  $dirmae = $ENV{DIRMAE};
  $anio = '2016';
  $centros = $dirmae . '/centros.csv';
  $sancionado = $dirmae . '/sancionado-' . $anio . '.csv';
  $porTrimestre = 0;
  listadoPS();
}

main();

# Lee el archivo de centros y llena el diccionario centrosHash
# con id_centro => nombre del centro
sub readCentros {
  my $centrosHashRef = shift;

  open(my $centrosFile, "<$centros") || die "ERROR: No puedo abrir el archivo $centros\n";

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

sub listadoPS {
  my %centrosHash;

  readCentros(\%centrosHash);

  open(my $sancionadoFile, "<$sancionado") || die "ERROR: No puedo abrir el archivo $sancionado\n";

  print "A\ño presupuestario $anio;Total Sancionado\n";
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
  foreach my $key (sort keys %data) {
    my $subtotal = 0;
    foreach my $items ( @{$data{$key}} ) {
      my $value = @$items[1];
      $subtotal += $value;
      print "@$items[0];" . dotToComma($value) . "\n";
    }
    $total += $subtotal;
    print "$key;" . dotToComma($subtotal) . "\n";
  }
  print "Total Anual" . dotToComma($total) . "\n";

  close($sancionadoFile);
}

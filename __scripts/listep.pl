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

# use strict;

# Definiciones

#
my $dirmae;
my $centros;
my $anio;
my $sancionado;

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
  $tc = 0;
  listadoPS(tc);
}

main();

# Lee el archivo de centros y llena el diccionario centrosHash
# con id_centro => nombre del centro
sub readCentros {

  open(my $centrosFile, "<$centros") || die "ERROR: No puedo abrir el archivo $centros\n";

  # Ignoro el header
  my $header = <$centrosFile>;
  while (my $line = <$centrosFile>) {
    chomp $line;
    my @fields = split(/;/, $line);
    $centrosHash{$fields[0]} = $fields[1];
  }

  close($centrosFile);
}

sub listadoPS {
  my $tc = $_[0];
  local %centrosHash;

  readCentros();

  open(my $sancionadoFile, "<$sancionado") || die "ERROR: No puedo abrir el archivo $sancionado\n";

  print "A\ño presupuestario $anio,Total Sancionado\n";
  # Ignoro el header
  my $header = <$sancionadoFile>;
  %data;

  while (my $line = <$sancionadoFile>) {
    my @fields = split(/;/, $line);
    my $centro = $centrosHash{$fields[0]};
    if (tc) {
      $firstKey = $centro; $secondKey = $fields[1];
    } else {
      $firstKey = $fields[1]; $secondKey = $centro;
    }

    if (!exists $data{$firstKey}) {
      $data{$firstKey} = [];
    }
    push(@{$data{$firstKey}}, [$secondKey, $fields[2] + $fields[3]]);
  }

  my $total = 0;
  foreach my $key (keys %data) {
    my $subtotal = 0;
    foreach my $items ( @{$data{$key}} ) {
      my $value = @$items[1];
      $subtotal += $value;
      print "@$items[0],$value\n";
    }
    $total += $subtotal;
    print "$key,$subtotal\n";
  }
  print "Total Anual,$total\n";

  my %centrosHash;
  close($sancionadoFile);
}

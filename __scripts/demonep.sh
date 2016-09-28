#!/bin/bash
# ******************************************************************
# Universidad de Buenos Aires					   *
# Facultad de Ingenieria					   *
#								   *
# 75.08 Sistemas Operativos					   *
# Catedra Ing. Osvaldo Clua					   *
#								   *
# Autores: Grupo 8						   *
#								   *
# ******************************************************************


#*******************************************************************
# 								   *
# OBLIGACIÓN DE INICIAR ANTES DE EJECUTAR CUALQUIER COMANDO        *
#								   *
#*******************************************************************

function verificarInicio {
  if [[ -z $GRUPO || -z $DIRBIN || -z $DIRMAE || -z $DIRREC || -z $DIROK ||
        -z $DIRPROC || -z $DIRINFO || -z $DIRLOG || -z $DIRNOK ]]; then
    return 1;
  fi
}


if ! verificarInicio; then
	echo "Primero debe ejecutar el initep.sh, por favor realizar el siguiente paso:
	. ./(path)/initep.sh ./(path)/instalep.conf"
	echo "ingrese una tecla para continuar"
	exit 1
fi


while [ 1 ]
do
	sleep 25000;
done

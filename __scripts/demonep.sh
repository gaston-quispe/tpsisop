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

#*******************************************************************
#							           *
# MANTENER UN CONTADOR DE CICLOS DE EJECUCIÓN DE DEMONEP	   *
#								   *
#*******************************************************************

log_command=$GRUPO/$DIRBIN/logep.sh

function loguearCantidadDeCiclos {
	$log_command "demonep" "Demonep ciclo nro. $cantidadDeCiclos" "INFO" "0"
	return 0	
}



cantidadDeCiclos=0

while true
do	
	let "cantidadDeCiclos+=1"
	loguearCantidadDeCiclos	
	sleep 5;
done

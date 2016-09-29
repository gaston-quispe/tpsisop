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


#******************************************************************
#								  *
# VERIFICAR QUE EL ARCHIVO SEA UN ARCHIVO COMÚN,DE TEXTO          *
#								  *
#******************************************************************

function verificarArchivoTexto() {
 	if [ ! -f $1 ]
        then
       		 $log_command "demonep" "El archivo: $1 fue rechazado, motivo: no es un archivo de texto"  "INFO" "0"
		 return 1
        fi
	return 0
}



#******************************************************************
#                                                                 *
# VERIFICAR QUE EL ARCHIVO NO ESTÉ VACIO                          *
#                                                                 *
#******************************************************************

function verificarArchivoVacio() {
	if [ ! -s $1 ]
	then
		$log_command "demonep" "El archivo: $1 fue rechazado, motivo: archivo vacio" "INFO" "0"
		return 1
	fi
	return 0
}


#*******************************************************************
#                                                                  *
#  VERIFICAR AÑO                                                   *    
#								   *
#*******************************************************************

function verificarAnio() {
	anio=$(echo $1 | cut -d'_' -f 2)
	anioActual="2016"
	if [ $anio -ne $anioActual ]
	then 
		$log_command "demonep" "El archivo: $1 fue rechazado, motivo: año $anio incorrecto" "INFO" "0"
		return 1
	fi
	return 0
}

#*******************************************************************
#                                                                  *
#  VERIFICAR PROVINCIA                                             *
#                                                                  *
#*******************************************************************

function verificarProvincia() {	
	 provincia=$(echo $1 | cut -d'_' -f 3)
	 archivoProvincia=$GRUPO/$DIRMAE/provincias.csv
	 match=$(cat "$archivoProvincia" | grep "^$provincia;.*$")
	 if [ $? -eq '1' ]
	 then 
		$log_command "demonep" "El archivo: $1 fue rechazado, motivo: provincia $provincia incorrecta" "INFO" "0"
                return 1
	 fi
	 return 0	 
}

#*******************************************************************
#                                                                  *
#  VERIFICAR FECHA                                                 *
#                                                                  *
#*******************************************************************

function verificarFecha() {
	 fecha=$(echo $nombre | cut -d'_' -f 4)
	 return 0
}


#*******************************************************************
#                                                                  *
#  VERIFICAR QUE EL FORMATO DEL NOMBRE DEL ARCHIVO SEA CORRECTO    *
#                                                                  *
#*******************************************************************

function verificarFormato() {
	nombreCompleto=${1##*/}
	if echo "$nombreCompleto" | grep "^ejecutado_.*_.*_.*.csv$" > /dev/null;
	then
		if verificarAnio "$nombreCompleto"
		then
			if verificarProvincia "$nombreCompleto"
			then
				if verificarFecha "$nombreCompleto"
				then
					return 0	
				fi 										
			fi					
		fi
		return 1
	else 
		$log_command "demonep" "El archivo: $1 fue rechazado, formato de nombre incorrecto" "INFO" "0"
		return 1
	fi
}




#*******************************************************************
#								   *
# CHEQUEA SI HAY ARCHIVOS EN EL DIRECTORIO $GRUPO/DIRREC	   *
#								   *
#*******************************************************************
ruta=$GRUPO/$DIRREC
function chequearArchivos {
        archivos="$ruta/*"

        for archivo in $archivos;
        do        
	      $log_command "demonep" "Archivo detectado: $archivo " "INFO" "0"
	      if  verificarArchivoTexto "$archivo" 
	      then			
			if verificarArchivoVacio "$archivo"
			then
				verificarFormato "$archivo"
			fi
	      fi
        done
	return 0
}



cantidadDeCiclos=0
chequearArchivos
while true
do	
	let "cantidadDeCiclos+=1"
	loguearCantidadDeCiclos		
	sleep 25;
done

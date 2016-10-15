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
	echo "ingrese una tecla para terminar"
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
	if [ -z $anio ]
	then
		$log_command "demonep" "El archivo: $1 fue rechazado, motivo: año $anio incorrecto" "INFO" "0"
                return 1
        fi
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
	 DATE=${DATE_COMMAND:-date}
	 fechac=$(echo $1 | cut -d'_' -f 4)
	 fecha=${fechac%.*}
	 fechaActual="$($DATE --date="`$DATE +%F`" +%s)"
	 fechaPresupuestaria="$($DATE --date="2016-01-01" +%s)"
	 longitud=${#fecha}
	 cantidad="8"

#verifico que la longitud sea de 8 caracteres
	 if [ $longitud -ne $cantidad ]
	 then
		$log_command "demonep" "El archivo: $1 fue rechazado, motivo: fecha $fecha,longitud erronea" "INFO" "0"
		return 1
	 fi

#verifico que sean todos numeros
	 echo "$fecha" | grep "^[0-9]*$" > /dev/null;
	 if [ $? -eq '1' ]
	 then
                $log_command "demonep" "El archivo: $1 fue rechazado, motivo: fecha $fecha no numerica" "INFO" "0"
		return 1
	 fi

#verifico correcta fecha
         fechaFormat=$($DATE -d $fecha +%F)
         miFecha="$($DATE --date="$fechaFormat" +%s)"
	$DATE "+%F" -d "$fechaFormat" > /dev/null
	if [ $? -eq '1' ]
	then
                $log_command "demonep" "El archivo: $1 fue rechazado, motivo: fecha $fecha incorrecta" "INFO" "0"
		return 1
	fi

#verifico que la fecha no sea mayor a la fecha actual
	if [ $miFecha -gt $fechaActual ]
	then
               $log_command "demonep" "El archivo: $1 fue rechazado, motivo: fecha $fecha mayor a la fecha actual" "INFO" "0"
                return 1
	fi

#verifico que la fecha sea mayor a la fecha presupuestaria
	if [ $miFecha -lt $fechaPresupuestaria ]
	then
               $log_command "demonep" "El archivo: $1 fue rechazado, motivo: fecha $fecha menor a la fecha presupuestaria" "INFO" "0"
	 	return 1
	fi
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
movep=$GRUPO/$DIRBIN
function chequearArchivos {        
        cantidadDeArchivos=$(find $ruta -maxdepth 1 -type f| wc -l)
        cero="0"
        if [ $cantidadDeArchivos -gt $cero ]
        then
		archivos="$ruta/*"
        	for archivo in $archivos;
	        do
		      $log_command "demonep" "Archivo detectado: $archivo " "INFO" "0"
		      if  verificarArchivoTexto "$archivo"
		      then
				if verificarArchivoVacio "$archivo"
				then
					if  verificarFormato "$archivo"
					then	
						$log_command "demonep" "Archivo aceptado" "INFO" "0"
						$movep/movep.sh $archivo $GRUPO/$DIROK "demonep"
					else
						$movep/movep.sh $archivo $GRUPO/$DIRNOK "demonep"
					fi
				else
	                		$movep/movep.sh $archivo $GRUPO/$DIRNOK "demonep"
				fi
		      else
				$movep/movep.sh $archivo $GRUPO/$DIRONOK "demonep"
		      fi
	        done
	fi
		return 1
}


#******************************************************************
#								  *
# VER SI ARRANCA EL PROCEP					  *
#								  *
#******************************************************************

function ejecutarProcep {
	ok=$GRUPO/$DIROK
	cantidadDeArchivos=$(find $ok -maxdepth 1 -type f| wc -l)
	cero="0"
	corriendo=$(ps -e | grep procep.sh)
	if [ $cantidadDeArchivos -gt $cero ]
	then
		if [ -z $corriendo ]
		then
			#ejecutar procep
                        $GRUPO/$DIRBIN/procep.sh
			$log_command "initep" "procep corriendo bajo el no. $!" "INFO" "0"
                        return 0

		else
			$log_command "demonep" "Invocación de Procep pospuesta para el siguiente ciclo" "INFO" "0"
			return 1
		fi
	return 0
	fi
}

#*******************************************************************
#								   *
#  DORMIR UN TIEMPO X Y EMPEZAR UN NUEVO CICLO                     *
#								   *
#*******************************************************************


cantidadDeCiclos=0
while true
do
	chequearArchivos
	ejecutarProcep
	let "cantidadDeCiclos+=1"
	loguearCantidadDeCiclos
	sleep 25;
done

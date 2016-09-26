#!/bin/bash
# ******************************************************************
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Catedra Ing. Osvaldo Clua
#
# Autores: Grupo 8
#
# ******************************************************************

# Este script se tiene que ejecutar de la siguiente manera:
# . ./initep.sh /path/to/instalep.conf

function checkenv {
  if [[ -z $GRUPO || -z $DIRBIN || -z $DIRMAE || -z $DIRREC || -z $DIROK ||
        -z $DIRPROC || -z $DIRINFO || -z $DIRLOG || -z $DIRNOK ]]; then
    return 1;
  fi
}

# Función que verifica si las variables para logeo estan seteadas
function inicializarLogger {
	instalacionExitosa=0

	if [ -z $GRUPO ]; then
		echo "Falta el archivo de configuración del instalep, por favor reinstalar";
		instalacionExitosa=1
	fi

	 if [ -z $DIRBIN ]; then
		echo "Directorio de Ejecutables no creado, por favor reinstalar";
                instalacionExitosa=1
        fi

	if [ $instalacionExitosa -eq 0 ]; then
		# Dar permisos de ejecucion
		filename=$GRUPO/$DIRBIN/logep.sh

		chmod +x $filename;
		if [ $? -ne 0  ]; then
			echo "No se pudo agregar el permiso de ejecución al script $filename";
			instalacionExitosa=1
  		fi
	fi

	return $instalacionExitosa
}

# Función que verifica que todas las variables necesarias estén seteadas
function verificarVariables {
	instalacionExitosa=0

	if [ -z $GRUPO ]; then
		echo "Falta el archivo de configuración del instalep, por favor reinstalar";
		instalacionExitosa=1
	fi

	 if [ -z $DIRBIN ]; then
		echo "Directorio de Ejecutables no creado, por favor reinstalar";
                instalacionExitosa=1
        fi

	# Si no puedo escribir en el log, exijo que reinstale ahora	
 	if [ $instalacionExitosa -eq 1 ]; then
		return 1
	fi	

	if [ -z $DIRMAE ]; then
		$log_command "initep" "Directrio maestro no creado, por favor reinstalar" "ERR" "1"
		instalacionExitosa=1
	fi

        if [ -z $DIRREC ]; then
		$log_command "initep" "Directorio de Recepción de Novedades no creado, por favor reinstalar" "ERR" "1"
                instalacionExitosa=1
        fi

        if [ -z $DIROK ]; then
		$log_command "initep" "Directorio de Archivos Aceptados no creado, por favor reinstalar" "ERR" "1"
                instalacionExitosa=1
        fi

        if [ -z $DIRPROC ]; then
		$log_command "initep" "Directorio de Archivos Procesados no creado, por favor reinstalar" "ERR" "1"
                instalacionExitosa=1
        fi

        if [ -z $DIRINFO ]; then
		$log_command "initep" "Directorio de Reportes no creado, por favor reinstalar" "ERR" "1"
                instalacionExitosa=1
        fi

	if [ -z $DIRLOG ]; then
		$log_command "initep" "Falta el directorio de archivos de log, por favor reinstalar" "ERR" "1"
		instalacionExitosa=1 
	fi

	if [ -z $DIRMAE ]; then
		$log_command "initep" "Directorio de Archivos rechazados no creado, por favor reinstalar" "ERR" "1"
                instalacionExitosa=1
        fi		

 	if [ $instalacionExitosa -eq 0 ]; then
		return 0
	else
		return 1
	fi	
}

if [ ! -f $1 ]
then
	echo "Falta archivo de configuración - parámentro obligatorio";
	return 1;
fi

if  checkenv; then
	$GRUPO/$DIRBIN/logep.sh "initep" "Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente" "INFO" "1"
    	return 0;
else
	# Seteo todas las lineas del archivo de configuración como variables de entorno
	while IFS== read key value rest
	do
	  export $key="$value"
	done < "$1"
fi

if ! inicializarLogger; then
	echo "Por favor, reinstale el sistema";
	return 1
else
	export PATH=$PATH:$GRUPO/$DIRBIN
	log_command=$GRUPO/$DIRBIN/logep.sh
fi

# Verifico que todas las variables necesarias estén seteadas
if ! verificarVariables;
then
	$log_command "initep" "No se encontraron algunas de las variables necesarias en el archivo de configuración" "ERR" "1"
	return 1;
fi

# Seteo los permisos a los archivos
for filename in $GRUPO/$DIRBIN/*.sh; do
  chmod +x $filename;
  if [ $? -ne 0  ]; then
	$log_command "initep" "No se pudo agregar el permiso de ejecución al script $filename" "ERR" "1"
    return 1;
  fi
done

for filename in $GRUPO/$DIRMAE/*.csv; do
  chmod +r $filename;
  if [ $? -ne 0  ]; then
	$log_command "initep" "No se pudo agregar el permiso de lectura al script $filename" "WAR" "1"
    return 1;
  fi
done

$log_command "initep" "Estado del Sistema: INICIALIZADO" "INFO" "1"

echo "¿Desea efectuar la activación de Demonep? Si – No:"
select activate_daemon in "Si" "No"; do
    case $activate_daemon in
        Si )
            $GRUPO/$DIRBIN/demonep.sh &
            $log_command "initep" "Demonep corriendo bajo el no. $!" "INFO" "1" ;
            break;;
        No )
            echo "Para arrancar a mano tiene que ejecutar el siguiente comando,que se encuentra dentro del directorio bin: \n";
            echo "$ ./(PATH)/demonep.sh &";
            break;;
        * ) echo "Por favor, ingrese una opción válida.";;
    esac
done

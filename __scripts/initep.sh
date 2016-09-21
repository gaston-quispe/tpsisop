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


# Función que verifica que todas las variables necesarias estén seteadas
function verificarVariables {
	instalacionExitosa=0

	if [ -z $GRUPO ]; then
		echo "Falta el archivo de configuracion del instalep, por favor reinstalar"
		instalacionExitosa=1
	fi

	 if [ -z $DIRBIN ]; then
                echo "Directorio de Ejecutables  no creado, por favor reinstalar"
                instalacionExitosa=1
        fi

	if [ -z $DIRMAE ]; then
		echo "Directorio maestro no creado, por favor reinstalar"
		instalacionExitosa=1
	fi

        if [ -z $DIRREC ]; then
                echo "Directorio de Recepcion de Novedades no creado, por favor reinstalar"
                instalacionExitosa=1
        fi

        if [ -z $DIROK ]; then
                echo "Directorio de Archivos Aceptados  no creado, por favor reinstalar"
                instalacionExitosa=1
        fi

        if [ -z $DIRPROC ]; then
                echo "Directorio de Archivos Procesados  no creado, por favor reinstalar"
                instalacionExitosa=1
        fi

        if [ -z $DIRINFO ]; then
                echo "Directorio de Reportes  no creado, por favor reinstalar"
                instalacionExitosa=1
        fi

	if [ -z $DIRLOG ]; then
		echo "Falta el directorio de archivos de log, por favor reinstalar"
		instalacionExitosa=1 
	fi

	if [ -z $DIRMAE ]; then
                echo "Directorio de Archivos rechazados  no creado, por favor reinstalar"
                instalacionExitosa=1
        fi		

 	if [ $instalacionExitosa == 0 ]; then
		return 0
	else
		return 1
	fi
	
}

if  checkenv;
  then
    echo "Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente";
    return 0;
fi

if [ ! -f $1 ]
  then
    echo "Archivo de configuración no pasado!";
    return 1;
fi

# Seteo todas las lineas del archivo de configuración como variables de entorno
while IFS== read key value rest
do
  export $key="$value"
done < "$1"


# Verifico que todas las variables necesarias estén seteadas
if ! verificarVariables;
  then
    echo "No se encontró uno de las variables necesarias en el archivo de configuración!";
    return 1;
fi


export PATH=$PATH:$GRUPO/$DIRBIN

# Seteo los permisos a los archivos
for filename in $GRUPO/$DIRBIN/*.sh; do
  chmod +x $filename;
  if [ $? -ne 0  ]; then
    echo "No se pudieron agregar permisos de ejecucion al script $filename!";
    return 1;
  fi
done

for filename in $GRUPO/$DIRMAE/*.csv; do
  chmod +r $filename;
  if [ $? -ne 0  ]; then
    echo "No se pudieron agregar permisos de lectura al script $filename!";
    return 1;
  fi
done

log_command=$GRUPO/$DIRBIN/logep.sh

$log_command "Estado del Sistema: INICIALIZADO"

echo "¿Desea efectuar la activación de Demonep? Si – No:"
select activate_daemon in "Si" "No"; do
    case $activate_daemon in
        Si )
            $GRUPO/$DIRBIN/demonep.sh &;
            $log_command "Demonep corriendo bajo el no. $!";
            break;;
        No )
            echo "Para arrancar a mano tiene que ejecutar: \n";
            echo "$ demonep.sh &";
            break;;
        * ) echo "Por favor, ingrese una opción válida.";;
    esac
done

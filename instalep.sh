#! /bin/bash
# ******************************************************************
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Catedra Ing. Osvaldo Clua
#
# Autores: Grupo 08
#
# ******************************************************************

#####################################################
#################### FUNCIONES ######################
#####################################################

function listarDirectorios {
	$ARCHLOGGER "instalep" "Listando directorios" "INFO" "0" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Configuración: $GRUPO/$DIRCONF" "INFO" "1" "$GRUPO/$DIRCONF"
    if [ -f $GRUPO/$DIRCONF ]
    then
       ls -1 $GRUPO/$DIRCONF
    fi
	$ARCHLOGGER "instalep" ">Directorio de Ejecutables: $GRUPO/$DIRBIN" "INFO" "1" "$GRUPO/$DIRCONF"
    if [ -f $GRUPO/$DIRBIN ]
    then
        ls -1 $GRUPO/$DIRBIN
    fi
	$ARCHLOGGER "instalep" ">Directorio de Maestros y Tablas: $GRUPO/$DIRMAE" "INFO" "1" "$GRUPO/$DIRCONF"
    if [ -f $GRUPO/$DIRMAE ]
    then
    	ls -1 $GRUPO/$DIRMAE
    fi
	$ARCHLOGGER "instalep" ">Directorio de Recepción de Novedades: $GRUPO/$DIRREC" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos Aceptados: $GRUPO/$DIROK" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos Procesados: $GRUPO/$DIRPROC" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos de Reportes: $GRUPO/$DIRINFO" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos de Log: $GRUPO/$DIRLOG" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos Rechazados: $GRUPO/$DIRNOK" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Estado de la instalación: LISTA" "INFO" "1" "$GRUPO/$DIRCONF"
}

function setearDirectorios {
read -p "Defina el directorio de ejecutables ($GRUPO/bin):" dirbin_aux
    if [ ! -z "$dirbin_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de ejecutables: $GRUPO/$dirbin_aux" "INFO" "0" "$GRUPO/$DIRCONF"
     	DIRBIN=$dirbin_aux
    fi
    
read -p "Defina el directorio de Maestros y Tablas ($GRUPO/mae):" mae_aux
    if [ ! -z "$mae_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de Maestros y Tablas: $GRUPO/$mae_aux" "INFO" "0" "$GRUPO/$DIRCONF"
        DIRMAE=$mae_aux
    fi

read -p "Defina el directorio de recepción de novedades ($GRUPO/nov):" nov_aux
    if [ ! -z "$nov_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de recepción de novedades $GRUPO/$nov_aux" "INFO" "0" "$GRUPO/$DIRCONF"
        DIRREC=$nov_aux
    fi
    
read -p "Defina el directorio de Archivos Aceptados ($GRUPO/ok):" ok_aux
    if [ ! -z "$ok_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de Archivos Aceptados: $GRUPO/$ok_aux" "INFO" "0" "$GRUPO/$DIRCONF"
        DIROK=$ok_aux
    fi
    
read -p "Defina el directorio de Archivos Procesados ($GRUPO/imp):" imp_aux
    if [ ! -z "$imp_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de Archivos Procesados: $GRUPO/$imp_aux" "INFO" "0" "$GRUPO/$DIRCONF"
        DIRPROC=$imp_aux
    fi
    
read -p "Defina el directorio de Reportes ($GRUPO/rep):" rep_aux
    if [ ! -z "$rep_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de Reportes: $GRUPO/$rep_aux" "INFO" "0" "$GRUPO/$DIRCONF"
        DIRINFO=$rep_aux
    fi
    
read -p "Defina el directorio de log ($GRUPO/log):" log_aux
    if [ ! -z "$log_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de log: $GRUPO/$log_aux" "INFO" "0" "$GRUPO/$DIRCONF"
        DIRLOG=$log_aux
    fi
   
read -p "Defina el directorio de rechazados ($GRUPO/nok):" nok_aux
    if [ ! -z "$nok_aux" ]
    then
	$ARCHLOGGER "instalep" "Definido directorio de rechazados: $GRUPO/$nok_aux" "INFO" "0" "$GRUPO/$DIRCONF"
        DIRNOK=$nok_aux
    fi

while true
do
  read -p "Defina el espacio minimo libre para la recepción de archivos en Mbytes(100):" datasize_aux
    if [ -z "$datasize_aux" ]
    then
      datasize_aux=100
    fi

    espacioDisponible=$(df -k . | sed 1d | awk '{OFMT = "%.0f"; print $4/1024}')
    if [ $datasize_aux -gt $espacioDisponible ]
    then
	$ARCHLOGGER "instalep" "Insuficiente espacio en disco." "ERR" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" "Espacio disponible: $espacioDisponible Mb." "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" "Espacio requerido: $datasize_aux Mb." "INFO" "1" "$GRUPO/$DIRCONF"
      echo "Intentelo nuevamente."
      continue
    else
      DATASIZE=$datasize_aux
      break
    fi
done
}

function inicializarLogger {
	# Dar permisos de ejecucion
	filename=__scripts/logep.sh

	chmod +x $filename;
	if [ $? -ne 0  ]; then
		echo "No se pudo agregar el permiso de ejecución al script $filename";
		return 1
	fi

	return 0
}

function fecha {
	date "+Fecha: %d/%m/%y Hora: %H:%M:%S"
}

#####################################################
################ INICIO DEL PROGRAMA ################
#####################################################


echo "Iniciando instalación"

GRUPO=$PWD'/Grupo08'
DIRCONF='dirconf'
ARCHCONF=$GRUPO/$DIRCONF/instalep.conf

#Nombres de directorios por defecto
DIRBIN='bin'
DIRMAE='mae'
DIRREC='nov'
DIROK='ok'
DIRPROC='imp'
DIRINFO='rep'
DIRLOG='log'
DIRNOK='nok'

if ! inicializarLogger; then
	echo "Error inicializando logger";
	exit 0
fi

mkdir $GRUPO
mkdir $GRUPO/$DIRCONF
ARCHLOGGER=__scripts/logep.sh

$ARCHLOGGER "instalep" "Inicio del proceso" "INFO" "0" "$GRUPO/$DIRCONF"

#Detecto sistema ya instalado
if [ -f $ARCHCONF ]
then
	listarDirectorios
	exit 0
else
	setearDirectorios
fi

clear
listarDirectorios

cantidadIntentos=0
intentosPermitidos=2
instalacionFinalizada=false
while [ $cantidadIntentos -ne $intentosPermitidos ] && [ $instalacionFinalizada = false ]
do
	echo "Desea continuar con la instalación? (Si – No):"
	select continuar_instalacion in "Si" "No"; do
		case $continuar_instalacion in
			Si )
				$ARCHLOGGER "instalep" "Continuando con instalación" "INFO" "1" "$GRUPO/$DIRCONF"
				$ARCHLOGGER "instalep" "Creando Estructuras de directorio. . ." "INFO" "0" "$GRUPO/$DIRCONF"
                
				mkdir $GRUPO/$DIRBIN
				mkdir $GRUPO/$DIRMAE
				mkdir $GRUPO/$DIRREC
				mkdir $GRUPO/$DIROK
				mkdir $GRUPO/$DIRPROC #ver porque en el tp tiene otro nombre
				mkdir $GRUPO/$DIRINFO
				mkdir $GRUPO/$DIRLOG
				mkdir $GRUPO/$DIRNOK
					
				#Escritura de archivo instalep.conf
				if [ -f $ARCHCONF ]
				then
	    				rm $ARCHCONF
				fi
				touch $ARCHCONF

				echo GRUPO=$GRUPO=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIRBIN=$DIRBIN=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIRMAE=$DIRMAE=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIRREC=$DIRREC=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIROK=$DIROK=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIRPROC=$DIRPROC=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIRINFO=$DIRINFO=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIRLOG=$DIRLOG=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF
				echo DIRNOK=$DIRNOK=$USER=$(date "+%d/%m/%Y %I:%M %P")>>$ARCHCONF

				$ARCHLOGGER "instalep" "Instalando Programas y Funciones" "INFO" "0" "$GRUPO/$DIRCONF"
				cp __scripts/* $GRUPO/$DIRBIN

				$ARCHLOGGER "instalep" "Instalando Archivos Maestros y Tablas" "INFO" "0" "$GRUPO/$DIRCONF"
				cp __mae/* $GRUPO/$DIRMAE
				instalacionFinalizada=true
		        break;;
		    No)
				((cantidadIntentos++))
				if [ $cantidadIntentos -ne $intentosPermitidos ]
				then
			        #Volver a pedir nombres de directorios
					setearDirectorios
				else
					instalacionFinalizada=true
				fi
		            break;;
		        * ) echo "Ingrese una opción válida.";;
		esac
	done
done

$ARCHLOGGER "instalep" "Fin del proceso. Usuario: $USER" "INFO" "1" "$GRUPO/$DIRCONF"
fechaAux=$(fecha)
$ARCHLOGGER "instalep" "$fechaAux" "INFO" "1" "$GRUPO/$DIRCONF"



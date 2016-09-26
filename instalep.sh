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
	$ARCHLOGGER "instalep" ">Directorio de Configuración: $GRUPO/$DIRCONF" "INFO" "1" "$GRUPO/$DIRCONF"
    if [ -f $ARCHCONF ]
    then
       ls -l "$GRUPO/$DIRCONF"
       echo
    fi
	$ARCHLOGGER "instalep" ">Directorio de Ejecutables: $GRUPO/$DIRBIN" "INFO" "1" "$GRUPO/$DIRCONF"
    if [ -f $ARCHCONF ]
    then
        ls -l "$GRUPO/$DIRBIN"
        echo
    fi
    echo ">Directorio de Maestros y Tablas: $GRUPO/$DIRMAE"
    if [ -f $ARCHCONF ]
    then
    	ls -l "$GRUPO/$DIRMAE"
        echo
    fi
	$ARCHLOGGER "instalep" ">Directorio de Recepción de Novedades: $GRUPO/$DIRREC" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos Aceptados: $GRUPO/$DIROK" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos Procesados: $GRUPO/$DIRPROC" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos de Reportes: $GRUPO/$DIRINFO" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos de Log: $GRUPO/$DIRLOG" "INFO" "1" "$GRUPO/$DIRCONF"
	$ARCHLOGGER "instalep" ">Directorio de Archivos Rechazados: $GRUPO/$DIRNOK" "INFO" "1" "$GRUPO/$DIRCONF"
}

function cargarDirectorios {
    DIRBIN=$(grep "DIRBIN" "$ARCHCONF"|cut -d'=' -f2)
    DIRMAE=$(grep "DIRMAE" "$ARCHCONF"|cut -d'=' -f2)
    DIRREC=$(grep "DIRREC" "$ARCHCONF"|cut -d'=' -f2)
    DIROK=$(grep "DIROK" "$ARCHCONF"|cut -d'=' -f2)
    DIRPROC=$(grep "DIRPROC" "$ARCHCONF"|cut -d'=' -f2)
    DIRINFO=$(grep "DIRINFO" "$ARCHCONF"|cut -d'=' -f2)
    DIRLOG=$(grep "DIRLOG" "$ARCHCONF"|cut -d'=' -f2)
    DIRNOK=$(grep "DIRNOK" "$ARCHCONF"|cut -d'=' -f2)
}

function setearUnDirectorio {
    # $1 : mensaje a mostrar
    # $2 : directorio por defecto
    # $3 : variable donde guardar el directorio leido
    
    while true
    do
        read -p ">$1 ($2):" dir_aux
        if [ -z "$dir_aux" ]
        then
            break
        else
            if [ "$dir_aux" != "$DIRCONF" ]
            then
             	eval "$3='$dir_aux'"
                break
            else
		$ARCHLOGGER "instalep" "El nombre que intenta elegir se encuentra reservado. Intente nuevamente." "ERR" "1" "$GRUPO/$DIRCONF"
            fi
        fi
    done
}

function setearDirectorios {

    setearUnDirectorio "Defina el directorio de Ejecutables" "$GRUPO/$DIRBIN" DIRBIN
    setearUnDirectorio "Defina el directorio de Maestros y Tablas" "$GRUPO/$DIRMAE" DIRMAE
    setearUnDirectorio "Defina el directorio de Recepción de Novedades" "$GRUPO/$DIRREC" DIRREC
    setearUnDirectorio "Defina el directorio de Archivos Aceptados" "$GRUPO/$DIROK" DIROK
    setearUnDirectorio "Defina el directorio de Archivos Procesados" "$GRUPO/$DIRPROC" DIRPROC
    setearUnDirectorio "Defina el directorio de Reportes" "$GRUPO/$DIRINFO" DIRINFO
    setearUnDirectorio "Defina el directorio de Log" "$GRUPO/$DIRLOG" DIRLOG
    setearUnDirectorio "Defina el directorio de Rechazados" "$GRUPO/$DIRNOK" DIRNOK

    while true
    do
        while true
        do
            read -p ">Defina el espacio mínimo libre para la recepción de archivos en Mbytes(100):" datasize_aux
            if [ -z "$datasize_aux" ]
            then
                datasize_aux=100
                break
            else
                regex='^[0-9]+$'
                if [[ "$datasize_aux" =~ $regex ]] && [ "$datasize_aux" -gt 0 ]
                then
                    break
                else
                    echo "El espacio mínimo debe ser un numero entero positivo! Intente nuevamente."
                fi
            fi
        done

        espacioDisponible=$(df -k . | sed 1d | awk '{OFMT = "%.0f"; print $4/1024}')
        if [ $datasize_aux -gt $espacioDisponible ]
        then
		$ARCHLOGGER "instalep" "Insuficiente espacio en disco." "ERR" "1" "$GRUPO/$DIRCONF"
		$ARCHLOGGER "instalep" "Espacio disponible: $espacioDisponible Mb." "ERR" "1" "$GRUPO/$DIRCONF"
		$ARCHLOGGER "instalep" "Espacio requerido: $datasize_aux Mb." "ERR" "1" "$GRUPO/$DIRCONF"
		$ARCHLOGGER "instalep" "Intentelo nuevamente." "ERR" "1" "$GRUPO/$DIRCONF"
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

GRUPO="$PWD/Grupo08"
DIRCONF="dirconf"
ARCHCONF="$GRUPO/$DIRCONF/instalep.conf"

#Nombres de directorios por defecto
DIRBIN=bin
DIRMAE=mae
DIRREC=nov
DIROK=ok
DIRPROC=imp
DIRINFO=rep
DIRLOG=log
DIRNOK=nok

if ! inicializarLogger; then
	echo "Error inicializando logger";
	exit 0
fi

#Creo directorio de configuracion
mkdir -p "$GRUPO/$DIRCONF"
ARCHLOGGER=__scripts/logep.sh

$ARCHLOGGER "instalep" "Inicio del proceso" "INFO" "0" "$GRUPO/$DIRCONF"

#Detecto sistema ya instalado
if [ -f "$ARCHCONF" ]
then
    cargarDirectorios
    echo "******************************************************"
    echo "*   *  * * EL SISTEMA EPLAM YA SE ENCUENTRA * *  *   *"
    echo "*   *  * * * * * * * INSTALADO!!! * * * * * * *  *   *"
    echo "******************************************************"
	listarDirectorios
	exit 0
else
    echo "******************************************************"
    echo "*   *  * *   INSTALACIÓN DEL SISTEMA EPLAM  * *  *   *"
    echo "******************************************************"
    echo "Iniciando instalación. . ."
	setearDirectorios
fi

clear

listarDirectorios
echo ">Estado de la instalación: LISTA"

cantidadIntentos=0
intentosPermitidos=2
instalacionFinalizada=false
while [ $cantidadIntentos -ne $intentosPermitidos ] && [ $instalacionFinalizada = false ]
do
    echo ">Desea continuar con la instalación? (Si – No):"
	select continuar_instalacion in "Si" "No"; do
		case $continuar_instalacion in
			Si )
				$ARCHLOGGER "instalep" "Creando Estructuras de directorio. . ." "INFO" "0" "$GRUPO/$DIRCONF"
                
                mkdir -p "$GRUPO"
				mkdir -p "$GRUPO/$DIRBIN"
				mkdir -p "$GRUPO/$DIRMAE"
				mkdir -p "$GRUPO/$DIRREC"
				mkdir -p "$GRUPO/$DIROK"
				mkdir -p "$GRUPO/$DIRPROC" #ver porque en el tp tiene otro nombre
				mkdir -p "$GRUPO/$DIRINFO"
				mkdir -p "$GRUPO/$DIRLOG"
				mkdir -p "$GRUPO/$DIRNOK"
					
				#Escritura de archivo instalep.conf
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

				echo "Instalando Programas y Funciones"
				cp __scripts/* "$GRUPO/$DIRBIN"
                chmod +x "$GRUPO/$DIRBIN"/*.sh 

				echo "Instalando Archivos Maestros y Tablas"
				cp __mae/* "$GRUPO/$DIRMAE"
			
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

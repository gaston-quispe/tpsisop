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
    echo ">Directorio de Configuración: $GRUPO/$DIRCONF"
    if [ -f $ARCHCONF ]
    then
       ls -l $GRUPO/$DIRCONF
       echo
    fi
    echo ">Directorio de Ejecutables: $GRUPO/$DIRBIN"
    if [ -f $ARCHCONF ]
    then
        ls -l $GRUPO/$DIRBIN
        echo
    fi
    echo ">Directorio de Maestros y Tablas: $GRUPO/$DIRMAE"
    if [ -f $ARCHCONF ]
    then
    	ls -l $GRUPO/$DIRMAE
        echo
    fi
    echo ">Directorio de Recepción de Novedades: $GRUPO/$DIRREC"
    echo ">Directorio de Archivos Aceptados: $GRUPO/$DIROK"
    echo ">Directorio de Archivos Procesados: $GRUPO/$DIRPROC"
    echo ">Directorio de Archivos de Reportes: $GRUPO/$DIRINFO"
    echo ">Directorio de Archivos de Log: $GRUPO/$DIRLOG"
    echo ">Directorio de Archivos Rechazados: $GRUPO/$DIRNOK"
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

function setearDirectorios {
read -p "Defina el directorio de ejecutables ($GRUPO/$DIRBIN):" dirbin_aux
    if [ ! -z "$dirbin_aux" ]
    then
     	DIRBIN=$dirbin_aux
    fi
    
read -p "Defina el directorio de Maestros y Tablas ($GRUPO/$DIRMAE):" mae_aux
    if [ ! -z "$mae_aux" ]
    then
        DIRMAE=$mae_aux
    fi

read -p "Defina el directorio de recepción de novedades ($GRUPO/$DIRREC):" nov_aux
    if [ ! -z "$nov_aux" ]
    then
        DIRREC=$nov_aux
    fi
    
read -p "Defina el directorio de Archivos Aceptados ($GRUPO/$DIROK):" ok_aux
    if [ ! -z "$ok_aux" ]
    then
        DIROK=$ok_aux
    fi
    
read -p "Defina el directorio de Archivos Procesados ($GRUPO/$DIRPROC):" imp_aux
    if [ ! -z "$imp_aux" ]
    then
        DIRPROC=$imp_aux
    fi
    
read -p "Defina el directorio de Reportes ($GRUPO/$DIRINFO):" rep_aux
    if [ ! -z "$rep_aux" ]
    then
        DIRINFO=$rep_aux
    fi
    
read -p "Defina el directorio de log ($GRUPO/$DIRLOG):" log_aux
    if [ ! -z "$log_aux" ]
    then
        DIRLOG=$log_aux
    fi
   
read -p "Defina el directorio de rechazados ($GRUPO/$DIRNOK):" nok_aux
    if [ ! -z "$nok_aux" ]
    then
        DIRNOK=$nok_aux
    fi

while true
do
    while true
    do
        read -p "Defina el espacio mínimo libre para la recepción de archivos en Mbytes(100):" datasize_aux
        if [ -z "$datasize_aux" ]
        then
            datasize_aux=100
            break
        else
            regex='^[0-9]+$'
            if [[ "$datasize_aux" =~ $regex ]]
            then
               break
            else
               echo "El espacio mínimo debe ser un numero entero! Reintente."
            fi
        fi
    done

    espacioDisponible=$(df -k . | sed 1d | awk '{OFMT = "%.0f"; print $4/1024}')
    if [ $datasize_aux -gt $espacioDisponible ]
    then
      echo "Insuficiente espacio en disco."
      echo "Espacio disponible:" $espacioDisponible "Mb."
      echo "Espacio requerido:" $datasize_aux "Mb."
      echo "Intentelo nuevamente."
      continue
    else
      DATASIZE=$datasize_aux
      break
    fi
done
}

#####################################################
################ INICIO DEL PROGRAMA ################
#####################################################

GRUPO=$PWD/Grupo08
DIRCONF=dirconf
ARCHCONF=$GRUPO/$DIRCONF/instalep.conf
ARCHLOG=$GRUPO/$DIRCONF/instalep.log

#Nombres de directorios por defecto
DIRBIN=bin
DIRMAE=mae
DIRREC=nov
DIROK=ok
DIRPROC=imp
DIRINFO=rep
DIRLOG=log
DIRNOK=nok

#Creo archivo para log
mkdir -p $GRUPO/$DIRCONF
touch $ARCHLOG

#Detecto sistema ya instalado
if [ -f $ARCHCONF ]
then
    cargarDirectorios
    echo "*****************************************************"
    echo "*   *  *  * LA APLICACIÓN YA SE ENCUENTRA *  *  *   *"
    echo "*   *  *  * * * * * *INSTALADA!!!!* * * * *  *  *   *"
    echo "*****************************************************"
	listarDirectorios
	exit 0
else
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
	echo "Desea continuar con la instalación? (Si – No):"
	select continuar_instalacion in "Si" "No"; do
		case $continuar_instalacion in
			Si )
				echo "Creando Estructuras de directorio. . ."
                
                mkdir -p $GRUPO
				mkdir -p $GRUPO/$DIRBIN
				mkdir -p $GRUPO/$DIRMAE
				mkdir -p $GRUPO/$DIRREC
				mkdir -p $GRUPO/$DIROK
				mkdir -p $GRUPO/$DIRPROC #ver porque en el tp tiene otro nombre
				mkdir -p $GRUPO/$DIRINFO
				mkdir -p $GRUPO/$DIRLOG
				mkdir -p $GRUPO/$DIRNOK
					
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
				cp __scripts/* $GRUPO/$DIRBIN
                chmod +x $GRUPO/$DIRBIN/*.sh 

				echo "Instalando Archivos Maestros y Tablas"
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

echo "Fin del proceso. Usuario:"
date "+Fecha: %d/%m/%y Hora: %H:%M:%S"

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
DIRNOK='nov'

mkdir $GRUPO

function listarDirectorios {
        echo "Directorio de Configuración: $GRUPO/$DIRCONF"
	ls -l $GRUPO/$DIRCONF
        echo "Directorio de Ejecutables: $GRUPO/$DIRBIN"
	ls -l $GRUPO/$DIRBIN
        echo "Directorio de Maestros y Tablas: $GRUPO/$DIRMAE"
	ls -l $GRUPO/$DIRMAE
        echo "Directorio de Recepción de Novedades: $GRUPO/$DIRREC"
        echo "Directorio de Archivos Aceptados: $GRUPO/$DIROK"
        echo "Directorio de Archivos Procesados: $GRUPO/$DIRPROC"
        echo "Directorio de Archivos de Reportes: $GRUPO/$DIRINFO"
        echo "Directorio de Archivos de Log: $GRUPO/$DIRLOG"
        echo "Directorio de Archivos Rechazados: $GRUPO/$DIRNOK"
        echo "Estado de la instalación: LISTA"
}

function setearDirectorios {
read -p "Defina el directorio de ejecutables ($GRUPO/bin):" dirbin_aux
    if [ ! -z "$dirbin_aux" ]
    then
     	DIRBIN=$dirbin_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Maestros y Tablas ($GRUPO/mae):" mae_aux
    if [ ! -z "$mae_aux" ]
    then
        DIRMAE=$mae_aux #<<< REALIZAR MAS VALIDACIONES!
    fi

read -p "Defina el directorio de recepción de novedades ($GRUPO/nov):" nov_aux
    if [ ! -z "$nov_aux" ]
    then
        DIRREC=$nov_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Archivos Aceptados ($GRUPO/ok):" ok_aux
    if [ ! -z "$ok_aux" ]
    then
        DIROK=$ok_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Archivos Procesados ($GRUPO/imp):" imp_aux
    if [ ! -z "$imp_aux" ]
    then
        DIRPROC=$imp_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Reportes ($GRUPO/rep):" rep_aux
    if [ ! -z "$rep_aux" ]
    then
        DIRINFO=$rep_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de log ($GRUPO/log):" log_aux
    if [ ! -z "$log_aux" ]
    then
        DIRLOG=$log_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
   
read -p "Defina el directorio de rechazados ($GRUPO/nok):" nok_aux
    if [ ! -z "$nok_aux" ]
    then
        DIRNOK=$nok_aux #<<< REALIZAR MAS VALIDACIONES!
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
      echo "Insuficiente espacio en disco."
      echo "Espacio disponible:" $espacioDisponible "Mb."
      echo "Espacio requerido:" $datasize_aux "Mb."
      echo "Intentelo nuevamente."
      continue
    else
      DATASIZE=$datasize_aux #<<< REALIZAR MAS VALIDACIONES!
      break
    fi
done
}

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
				echo "Creando Estructuras de directorio. . ."
				mkdir $GRUPO/$DIRCONF
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

				echo "Instalando Programas y Funciones"
				cp __scripts/* $GRUPO/$DIRBIN

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

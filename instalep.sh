#! /bin/bash
# ******************************************************************
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Catedra Ing. Osvaldo Clua
#
# Autores: Gaston Quispe, Valeria Rocha.
#
# ******************************************************************

echo "Iniciando instalación"
echo "prueba de commit"
GRUPO='Grupo08'
mkdir $GRUPO
mkdir $GRUPO/dirconf
read -p "Defina el directorio de ejecutables ($GRUPO/bin):" dirbin_aux
    if [ -z "$dirbin_aux" ]
    then
      DIRBIN='bin'
    else
      DIRBIN=$dirbin_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Maestros y Tablas ($GRUPO/mae):" mae_aux
    if [ -z "$mae_aux" ]
      then
        DIRMAE='mae'
      else
        DIRMAE=$mae_aux #<<< REALIZAR MAS VALIDACIONES!
    fi

read -p "Defina el directorio de recepción de novedades ($GRUPO/nov):" nov_aux
    if [ -z "$nov_aux" ]
      then
        DIRREC='nov'
      else
        DIRREC=$nov_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Archivos Aceptados ($GRUPO/ok):" ok_aux
    if [ -z "$ok_aux" ]
      then
        DIROK='ok'
      else
        DIROK=$ok_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Archivos Procesados ($GRUPO/imp):" imp_aux
    if [ -z "$imp_aux" ]
      then
        DIRPROC='imp'
      else
        DIRPROC=$imp_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de Reportes ($GRUPO/rep):" rep_aux
    if [ -z "$rep_aux" ]
      then
        DIRINFO='rep'
      else
        DIRINFO=$rep_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de log ($GRUPO/log):" log_aux
    if [ -z "$log_aux" ]
      then
        DIRLOG='log'
      else
        DIRLOG=$log_aux #<<< REALIZAR MAS VALIDACIONES!
    fi
    
read -p "Defina el directorio de rechazados ($GRUPO/nok):" nok_aux
    if [ -z "$nok_aux" ]
      then
        DIRNOK='nok'
      else
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

#Falta validacion de espacio en disco.

echo "Directorio de Configuración: $DIRBIN"
echo "Directorio de Ejecutables: ($GRUPO/DIRBIN mostrar path y listar archivos)"
echo "Directorio de Maestros y Tablas: ($GRUPO/DIRMAE mostrar path y listar archivos)"
echo "Directorio de Recepción de Novedades: ($GRUPO/DIRREC mostrar path)"
echo "Directorio de Archivos Aceptados: ($GRUPO/DIROK mostrar path)"
echo "Directorio de Archivos Procesados: ($GRUPO/DIRPROC mostrar path)"
echo "Directorio de Archivos de Reportes: ($GRUPO/DIRINFO mostrar path)"
echo "Directorio de Archivos de Log: ($GRUPO/DIRLOG mostrar path)"
echo "Directorio de Archivos Rechazados: ($GRUPO/DIRNOK mostrar path)"
echo "Estado de la instalación: LISTA"
echo "Desea continuar con la instalación? (Si – No)"

echo "Creando Estructuras de directorio. . ."
mkdir $GRUPO/$DIRBIN
mkdir $GRUPO/$DIRMAE
mkdir $GRUPO/$DIRREC
mkdir $GRUPO/$DIROK
mkdir $GRUPO/$DIRPROC #ver por qué en el tp tiene otro nombre
mkdir $GRUPO/$DIRINFO
mkdir $GRUPO/$DIRLOG
mkdir $GRUPO/$DIRNOK

echo "Instalando Programas y Funciones"
echo "Instalando Archivos Maestros y Tablas"
echo "Fin del proceso. Usuario Fecha y Hora"

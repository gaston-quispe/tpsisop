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
GRUPO='Grupo08'
mkdir $GRUPO
mkdir $GRUPO/dirconf

read -p "Defina el directorio de ejecutables ($GRUPO/bin):" dirbin_aux
    DIRBIN=$dirbin_aux #<<< REALIZAR VALIDACIONES!
    
read -p "Defina el directorio de Maestros y Tablas ($GRUPO/mae):" mae_aux
    DIRMAE=$mae_aux #<<< REALIZAR VALIDACIONES!

read -p "Defina el directorio de recepción de novedades ($GRUPO/nov):" nov_aux
    DIRREC=$nov_aux #<<< REALIZAR VALIDACIONES!
    
read -p "Defina el directorio de Archivos Aceptados ($GRUPO/ok):" ok_aux
    DIROK=$ok_aux #<<< REALIZAR VALIDACIONES!
    
read -p "Defina el directorio de Archivos Procesados ($GRUPO/imp):" imp_aux
    DIRPROC=$imp_aux #<<< REALIZAR VALIDACIONES!
    
read -p "Defina el directorio de Reportes ($GRUPO/rep):" rep_aux
    DIRINFO=$rep_aux #<<< REALIZAR VALIDACIONES!
    
read -p "Defina el directorio de log ($GRUPO/log):" log_aux
    DIRLOG=$log_aux #<<< REALIZAR VALIDACIONES!
    
read -p "Defina el directorio de rechazados ($GRUPO/nok):" nok_aux
    DIRNOK=$nok_aux #<<< REALIZAR VALIDACIONES!
    
read -p "Defina el espacio minimo libre para la recepción de archivos en Mbytes(100):" datasize_aux
    DATASIZE=$datasize_aux #<<< REALIZAR VALIDACIONES!
    
clear
echo "Directorio de Configuración: $DIRBIN"

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
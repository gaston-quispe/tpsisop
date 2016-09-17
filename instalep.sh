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
    
read -p "Defina el directorio de Archivos Procesados ($GRUPO/imp):" imp_aux
    DIRINFO=$imp_aux #<<< REALIZAR VALIDACIONES!

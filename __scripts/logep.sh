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


# el parametro 1 es el origen
# el parametro 2 es el mensaje
# el parametro 3 es el tipo de mensaje
# el parametro 4 depende de:
#	0) logueo
#	1) logueo y mostrar

archivo=$GRUPO/$DIRLOG/$1.log

if [ ! -f $achivo ]
then
	touch $archivo
elif [ stat -c%s "$archivo" > 1000 ]
then
	# TODO: usar movep para no perder el log anterior
	> $archivo
	echo "Log Excedido" >> $archivo	
fi

echo  "$2  -  $3" >> $archivo

if [ $4 == 1 ]
then
	echo $2
fi


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
# el parametro 5 es el path destino del log


# recibe por parameto $1 el archivo log original
# recibe por parameto $2 el path destino del log
# mantiene en el log las ultimas m lineas cuando es excedido
function podarLog {

	cantLineasAconservar=10;
	cabecera="<<Log Excedido..>>"
	
	archivoTemp=$path/logTemporal.txt
	
	touch $archivo

	echo $cabecera >> $archivoTemp
	cat "$1" | tail -"$cantLineasAconservar" >> "$archivoTemp"
	cat "$archivoTemp" > "$1"
	rm "$archivoTemp"
}

function timestamp {
	date "+%d/%m/%y %H:%M:%S"
}

function main {
	if [ ! $5 == "" ]; then
		path=$5		
	else
		path=$GRUPO/$DIRLOG
	fi

	archivo=$path/$1.log

	cantLineasPermitidas=12

	if [ ! -f $achivo ]; then
		touch $archivo
	fi

	echo "$USER - $(timestamp) : $2  -  $3" >> $archivo

	cantLineasArchivo=$(wc -l "$archivo" | cut -f1 -d' ')

	if [ $cantLineasArchivo -gt $cantLineasPermitidas ]; then
		
		podarLog $archivo $path
	fi


	if [ $4 == 1 ]; then
		echo $2
	fi

}

main "$1" "$2" "$3" "$4" "$5"

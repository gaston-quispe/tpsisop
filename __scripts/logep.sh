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



# recibe por parameto $1 el archivo log original
# mantiene en el log las ultimas m lineas cuando es excedido
function podarLog {

	cantLineasAconservar=10;
	cabecera="<<Log Excedido..>>"
	
	archivoTemp=$GRUPO/$DIRLOG/logTemporal.txt
	
	touch $archivo

	echo $cabecera >> $archivoTemp
	cat "$1" | tail -"$cantLineasAconservar" >> "$archivoTemp"
	cat "$archivoTemp" > "$1"
	rm "$archivoTemp"
}


function main {

	archivo=$GRUPO/$DIRLOG/$1.log
	cantLineasPermitidas=12

	if [ ! -f $achivo ]; then

		touch $archivo
	fi

	echo  "$2  -  $3" >> $archivo

	
	cantLineasArchivo=$(wc -l "$archivo" | cut -f1 -d' ')

	if [ $cantLineasArchivo -gt $cantLineasPermitidas ]; then
		
		podarLog $archivo
	fi


	if [ $4 == 1 ]; then
		echo $2
	fi

}

main "$1" "$2" "$3" "$4"

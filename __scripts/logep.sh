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

	cantLineasAconservar=50;
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


#valida si el archivo log supera el tamanio permitido
#$1 es el archivo
function validarTamanioLog {

	#valida que no supere 2K de datos
  # Uso wc -c para tener una solución portable. Las implementaciones de wc
  # estandar deberian performar bien (sin leer todo el archivo)
	if [ $(wc -c < "$1") -gt $2  ];then
		return 1
	fi
	return 0
}



function main {

	logError=0 #exito

	#el argumento 3 es opcional por lo tanto si no se pasa por parametro se usa INFO por default
        if [[  "$3" != "WAR" && "$3" != "ERR" && "$3" != "INFO" ]]; then
                tipoMensaje="INFO"

                if [ -n "$5"  ]; then   #existe el parametro tipo mensaje $3 pero escribio mal el tipo mensaje se pone un WAR
			tipoMensaje="WAR"
                        argumentoMostrarMensaje=$4
                        argumentoDirectorio=$5
                else
                        argumentoMostrarMensaje=$3  #no existe el paramtro $3
                        argumentoDirectorio=$4
                fi
        else
                tipoMensaje=$3
                argumentoMostrarMensaje=$4
                argumentoDirectorio=$5
        fi




	if [[ ! "$argumentoDirectorio" == "" && -d "$argumentoDirectorio" ]]; then
		path=$argumentoDirectorio
	else
		if [[ -z $GRUPO || -z $DIRLOG ]]; then # validacion de las variables de ambiente
			logError=1
		fi
		path=$GRUPO/$DIRLOG
	fi

	archivo=$path/$1.log

  # La variable de entorno LOGSIZE tiene el tamaño máximo del log en kilobytes
	capacidadMaximaLog=$(expr ${LOGSIZE:-2} \* 1024)

	if [ ! -f $achivo ]; then
		touch $archivo
	fi

	echo "$USER - $(timestamp) - $2 -  $tipoMensaje" >> $archivo

	tamanioValido=$( validarTamanioLog $archivo $capacidadMaximaLog )
	if [ ! tamanioValido ]; then
		podarLog $archivo $path
	fi

	if [ $argumentoMostrarMensaje == 1 ]; then
		echo $2
	fi


	return $logError

}

main "$1" "$2" "$3" "$4" "$5"

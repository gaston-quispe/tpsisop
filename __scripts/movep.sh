#/bin/bash
#
#script que se encarga de mover los archivos
#
#parametro 1 origen del fichero a mover
#parametro 2 destino del fichero a mover
#parametro 3 comando que lo invoca

#$1 es el comando
#$2 es el mensaje
#$3 es el tipo de error
function grabarLog {
	tipoError=$3

	if [ -z "$tipoError"  ]; then
		tipoError="INFO"
	fi

	#caso especifico del inited
	if [ "$1" == "initep"  ];then
		logep "$1" "$2" "$tipoError" "0" "$GRUPO/dirconf/"
	else
		logep.sh "$1" "$2" "$tipoError" "0"
	fi
}


#$1 archivo con path completo
#$2 comando invocador
function obtenerSecuencia {
	pathArchivo=$1
	dirArchivo=$(dirname $pathArchivo)/
	archivo=${pathArchivo##*/}
	maxCantArchDupl=999
	rango=2
	cantArchivos=`ls $dirArchivo | grep -c "^${archivo}[.][1-9]\([0-9]\)\?\{$rango\}$"`
	let cantArchivos=$cantArchivos+1

	if [ $cantArchivos -gt $maxCantArchDupl ];then
		#loguear Error
		grabarLog "$2" "no se pudo mover porque el archivo $1 supero la secuencia maxima permitida de $maxCantArchDupl" "WAR"
		archivo=""
	else
		archivo=$archivo.$cantArchivos
		archivo=$dirArchivo$archivo
	fi

	echo $archivo
}


#$1 archivo origen
#$2 directorio destino
#$3 comando que lo invoca
function main {
	archivo=$1
	dirOrigen=$(dirname $archivo)/
	dirDestino=$2
	terminacionBarra="^.*/$"


	#if [ $# -lt 2 ] | [ $# -gt 3 ];then
	#	#loguear mensaje
	#	echo "cantidad de paramtros incorrectos"
	#	exit -1
	#fi

	comandos=(demonep listep initep procep)

	if [ -z "$3" ];then
		comando=movep
	else
		for i in ${comandos[*]}
		do
			if [ $i == $3 ];then
				comando=$3
				break
			else
				comando=movep
			fi
		done
	fi


	if ! [ -f $archivo ];then
		#loguear mensaje
		grabarLog "$comando" "no se pudo mover debido a que : $archivo no es un archivo " "WAR"
		exit -2
	fi


	if ! [ -d $dirDestino ];then
		grabarLog "$comando" "no se pudo mover debido a que : $dirDestino no es un directorio " "WAR"
		#loguear mensaje
		exit -3
	fi


	if  ! [[ $dirDestino  =~ $terminacionBarra ]];then
		dirDestino=$dirDestino/
	fi


	empiezaDelHome="^/.*/$"
	path=${PWD}

	if ! [[ $dirDestino =~ $empiezaDelHome ]];then
		#se tiene que agregar la ruta completa
		if  [ $dirDestino == "./" ];then
			dirDestino=$path/
		else
			dirDestino=$path/$dirDestino
		fi
	fi


	if ! [[ $dirOrigen =~ $empiezaDelHome ]];then
		#se tiene que agregar la ruta completa
		if [ $dirOrigen == "./" ];then
			dirOrigen=$path/
		else
			dirOrigen=$path/$dirOrigen
		fi
	fi

	archivoDestino=${archivo##*/}
	archivoDestinoDuplicado=$archivoDestino
	archivoDestino=$dirDestino$archivoDestino
	dirDestinoDuplicado=${dirDestino}dpl/
	archivoDestinoDuplicado=$dirDestinoDuplicado$archivoDestinoDuplicado


	if [ "$dirDestino" == "$dirOrigen" ]; then
		grabarLog "$comando" "no se pudo mover debido a que : el directorio destino y el directorio origen son el mismo " "WAR"
		#loguer mensaje
		exit -4
	fi


	if ! [ -f $archivoDestino ];then
		grabarLog "$comando" "el archivo $archivo se movio satisfactoriamente a $dirDestino " "INFO"
		mv $archivo $archivoDestino
	else
		if ! [ -d $dirDestinoDuplicado ];then
			mkdir $dirDestinoDuplicado
		fi

		archivoDestinoDuplicado=$(obtenerSecuencia $archivoDestinoDuplicado $comando)

		if [ -z $archivoDestinoDuplicado ];then
			exit -5
		fi

		grabarLog "$comando" "el archivo se encuentra duplicado en $dirDestino, y se movio a $dirDestinoDuplicado" "INFO"
		# echo "-----------------"
		# echo "archivo destino  $archivoDestinoDuplicado"
		# echo "archivo origen $archivo"
		# echo "-----------------"
		mv $archivo $archivoDestinoDuplicado
	fi

}

main "$1" "$2" "$3"

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

	logep.sh "$1" "$2" "$3" "0"
}


#$1 archivo con path completo
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
		rango=3 #pongo cualquier cosa para que no rompa el if
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

	comandos=(Demonep Listep Initep Procep)

	if [ -z "$3" ];then
		comando=Movep
	else
		for i in ${comandos[*]}
		do
			if [ $i == $3 ];then
				comando=$3
				break
			else
				comando=Movep
			fi
		done
	fi
	
	echo "____________"
	echo $comando


	if ! [ -f $archivo ];then
		#loguear mensaje
#		grabarLog "$comando" "no se pudo mover debido a que : $archivo no es un archivo " "WAR"
		echo "no existe el archivo"
		exit -2	
	fi

	if ! [ -d $dirDestino ];then
		echo "no existe el directorio"	
#		grabarLog "$comando" "no se pudo mover debido a que : $dirDestino no es un directorio " "WAR"
		#loguear mensaje
		exit -3
	fi

	if  ! [[ $dirDestino  =~ $terminacionBarra ]];then
		dirDestino=$dirDestino/	
	fi

	empiezaDelHome="^/home/.*/$"
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
		echo "directorios iguales"
#		grabarLog "$comando" "no se pudo mover debido a que : el directorio destino y el directorio origen son el mismo " "WAR"
		#loguer mensaje
		exit -4	
	fi


	if ! [ -f $archivoDestino ];then
		echo "pasa que no existe duplicado y se mueve normalmente el archivo"
#		grabarLog "$comando" "el archivo $archivo se movio satisfactoriamente a $dirDestino " "INFO"
		mv $archivo $archivoDestino				
	else
		if ! [ -d $dirDestinoDuplicado ];then
			mkdir $dirDestinoDuplicado
			echo "se crea el directorio duplicado"
		fi

		archivoDestinoDuplicado=$(obtenerSecuencia $archivoDestinoDuplicado)
#		grabarLog "$comando" "el archivo se encuentra duplicado en $dirDestino, y se movio a $archivoDestinoDuplicado" "INFO"
		echo "-----------------"
		echo "archivo destino  $archivoDestinoDuplicado"
		echo "archivo origen $archivo"
		echo "-----------------"
		mv $archivo $archivoDestinoDuplicado
	fi

}

main "$1" "$2" "$3"

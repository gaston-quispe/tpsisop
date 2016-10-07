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

function checkenv {
  if [[ -z $GRUPO || -z $DIRBIN || -z $DIRMAE || -z $DIRREC || -z $DIROK ||
        -z $DIRPROC || -z $DIRINFO || -z $DIRLOG || -z $DIRNOK ]]; then
    return 1;
  fi
}

if [ ! checkenv ]
then
	echo "Ambiente no inicializado"
	exit 1
fi

ARCHLOGGER=logep.sh

cantidadArchivos=$(ls $GRUPO/$DIRREC | wc -l)

$ARCHLOGGER "procep" "Cantidad de archivos a procesar: $cantidadArchivos" "INFO" "1"

#Verificar archivo duplicado.
echo $GRUPO/$DIRREC
listaArchivos=$(ls $GRUPO/$DIRREC)

for archivo in $listaArchivos
do
	if [ -f $GRUPO/$DIRPROC/$archivo ]
	then
		$ARCHLOGGER "procep" "Archivo Duplicado. Se rechaza el archivo $archivo" "INFO" "1"
		mv $GRUPO/$DIRREC/$archivo $GRUPO/$DIRNOK
	else
		linea=$(sed -n '2p' $GRUPO/$DIRREC/$archivo)
		regex='^(..*;){5}..*$'
		if [[ "$linea" =~ $regex ]]
		then
			echo "ok"
			while read -r linea
			do
				echo $linea
				#centro=$(cut -d';' -f3 $linea)
				#echo $centro
			done <$GRUPO/$DIRREC/$archivo
		else
			$ARCHLOGGER "procep" "Estructura inesperada. Se rechaza el archivo $archivo." "INFO" "1"
			#mv $GRUPO/$DIRREC/$archivo $GRUPO/$DIRNOK
		fi
	fi
done

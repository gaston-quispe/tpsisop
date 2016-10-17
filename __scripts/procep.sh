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

function fecha {
	date "+Fecha: %d/%m/%y Hora: %H:%M:%S"
}

function checkenv {
  if [[ -z $GRUPO || -z $DIRBIN || -z $DIRMAE || -z $DIRREC || -z $DIROK ||
        -z $DIRPROC || -z $DIRINFO || -z $DIRLOG || -z $DIRNOK ]]; then
    return 1;
  fi
}

function validarCampos {
nombreArchivo=$1
cantidadAceptados=0
cantidadRechazados=0

while read -r linea
do
	#Validacion Centro de Presupuestos
	IFS=";" read -ra CAMPOS <<< "$linea"
	id=${CAMPOS[0]}
	fecha=${CAMPOS[1]}
	centro=${CAMPOS[2]}
	actividad=${CAMPOS[3]}
	trimestre=${CAMPOS[4]}
	gasto=${CAMPOS[5]}

	#Extraccion de campos
	IFS=" " read -ra FECHA_PRESUPUESTO <<< "$trimestre"
	ANIO_PRESUPUESTARIO=${FECHA_PRESUPUESTO[2]}

	pathRechazado=$GRUPO/$DIRPROC/rechazado-$ANIO_PRESUPUESTARIO
	pathAceptado=$GRUPO/$DIRPROC/aceptado-$ANIO_PRESUPUESTARIO
	

	#Validacion de Centro
	lineaCentros=$( grep "$centro" $GRUPO/$DIRMAE/centros.csv )
	if [ -z "$lineaCentros" ]
	then
		#Si no existe el centro, el registro no es valido.
		#Loggearlo
		#Grabar registro rechazado
		touch $pathRechazado
		echo "$nombreArchivo;centro inexistente;$linea;$USER;$(fecha)"
		cantidadRechazados+=1
		continue
	fi

	#Extraccion de campos
	IFS=";" read -ra CAMPOS_CENTRO <<< "$lineaCentros"
	NOMBRE_CENTRO=${CAMPOS_CENTRO[1]}
	NOMBRE_PROVINCIA=""

	#Validacion de Actividad
	lineaActividades=$( grep "$actividad" $GRUPO/$DIRMAE/actividades.csv )
	if [ -z "$lineaActividades" ]
	then
		#Si no existe la actividad, el registro no es valido.
		#Loggearlo
		#Grabar registro rechazado
		touch $pathRechazado
		echo "$nombreArchivo;actividad inexistente;$linea;$USER;$(fecha)"
		cantidadRechazados+=1
		continue
	fi

	#Extraccion de campos
	IFS=";" read -ra CAMPOS_ACTIVIDAD <<< "$lineaActividades"
	CODIGO_ACTIVIDAD=${CAMPOS_ACTIVIDAD[0]}

	#Validacion de Trimestre
	lineaTrimestres=$( grep "$centro" $GRUPO/$DIRMAE/trimestres.csv )
	if [ -z "$lineaTrimestres" ]
	then
		#Si no existe el trimestre, el registro no es valido.
		#Loggearlo
		#Grabar registro rechazado
		touch $pathRechazado
		echo "$nombreArchivo;trimestre inexistente;$linea;$USER;$(fecha)"
		cantidadRechazados+=1		
		continue
	fi

	#Extraccion de campos
	IFS=";" read -ra CAMPOS_TRIMESTRE <<< "$lineaTrimestres"
	anioTrimestre=${CAMPO_TRIMESTRES[0]}
	nombreTrimestre=${CAMPO_TRIMESTRES[1]}
	FDESDE_TRI=${CAMPO_TRIMESTRES[2]}
	FHASTA_TRI=${CAMPO_TRIMESTRES[3]}
	
	anioCorriente="2016"
	if [ "$anioTrimestre" == "$anioCorriente" ]
	then	
		#Validacion de fecha valida
		echo "Prueba"
		#Validacion de rango de fecha
	else
		#Si el anio no es correcto, el registro no es valido
		#Loggearlo
		#Grabar registro rechazado
		touch $pathRechazado
		echo "$nombreArchivo;año no es correcto;$linea;$USER;$(fecha)"
		cantidadRechazados+=1		
		continue
	fi

	#Validacion de Gasto
	if [ $gasto < 0 ]
	then
		#Grabar el registro rechazado. Motivo: El gasto debe ser mayor a cero.
		touch $pathRechazado
		echo "$nombreArchivo;importe invalido;$linea;$USER;$(fecha)"
		cantidadRechazados+=1
		continue
	fi
	
	#Si el registro paso las validaciones, lo grabo como aceptado.
	touch $pathAceptado
	echo "$id;$fecha;$centro;$actividad;$trimestre;$gasto;$nombreArchivo;$CODIGO_ACTIVIDAD;$NOMBRE_PROVINCIA;$NOMBRE_CENTRO"
	cantidadAceptados+=1
done <$GRUPO/$DIRREC/$archivo
}

if [ ! checkenv ]
then
	echo "Ambiente no inicializado"
	exit 1
fi

ARCHLOGGER=logep.sh

cantidadArchivos=$(ls $GRUPO/$DIRREC | wc -l)
nRegistrosValidos=0

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
		#Verificacion de formato
		linea=$(sed -n '2p' $GRUPO/$DIRREC/$archivo)
		regex='^([^;]+;){5}[^;]+$'
		if [[ "$linea" =~ $regex ]]
		then
			echo "ok"
			#Validacion de campos
			$ARCHLOGGER "procep" "Archivo a procesar $archivo" "INFO" "1"
			validarCampos $archivo
		else
			$ARCHLOGGER "procep" "Estructura inesperada. Se rechaza el archivo $archivo." "INFO" "1"
			#mv $GRUPO/$DIRREC/$archivo $GRUPO/$DIRNOK
		fi
	fi
done

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

log_command=logep.sh
DATE=${DATE_COMMAND:-date}

function fecha {
	$DATE "+Fecha: %d/%m/%y Hora: %H:%M:%S"
}

function yyyymmdd {
    local fecha=$1
    local regex='^../../....$'
    if [[ "$fecha" =~ $regex ]]
    then
        fechaReformateada="${fecha:6:4}${fecha:3:2}${fecha:0:2}"
        echo $( $DATE -d "$fechaReformateada" +%Y%m%d)
    else
        echo $fecha
    fi
}

function fechaEntre {
    local fecha=$(yyyymmdd $1)
    local fechaInicial=$(yyyymmdd $2)
    local fechaFinal=$(yyyymmdd $3)

    if [ $fechaInicial -le $fecha -a $fecha -le $fechaFinal ]
    then
        echo 1
    else
        echo -1
    fi
}

function checkenv {
  if [[ -z $GRUPO || -z $DIRBIN || -z $DIRMAE || -z $DIRREC || -z $DIROK ||
        -z $DIRPROC || -z $DIRINFO || -z $DIRLOG || -z $DIRNOK ]]; then
    return 1;
  fi
}

function validarRegistros {
nombreArchivo=$1
cantidadLeidos=0
cantidadAceptados=0
cantidadRechazados=0

DONE=false
until $DONE
do
    read -r linea || DONE=true

	#echo "Registro a procesar: $linea"

	#************************************
	# Extraccion de campos del registro *
	#************************************
	IFS=";" read -ra CAMPOS <<< "$linea"
	id=${CAMPOS[0]}
	fecha=${CAMPOS[1]}
	centro=${CAMPOS[2]}
	actividad=${CAMPOS[3]}
	trimestre=${CAMPOS[4]}
	gasto=${CAMPOS[5]}

	#Salteo la linea de id de campos
	if [ $id = "ID_EJE" ]
	then
		continue
	fi

	((cantidadLeidos++))
	#echo "Nombre centro: $centro"
	#Extraccion del año presupuestario
	IFS=" " read -ra FECHA_PRESUPUESTO <<< "$trimestre"
	ANIO_PRESUPUESTARIO=${FECHA_PRESUPUESTO[2]}

	#Paths donde mover los registros
	pathRechazado=$GRUPO/$DIRPROC/rechazado-$ANIO_PRESUPUESTARIO
	pathAceptado=$GRUPO/$DIRPROC/aceptado-$ANIO_PRESUPUESTARIO


	#**********************************
	#	Validacion de Centro      *
	#**********************************
	lineaCentros=$( grep "$centro" $GRUPO/$DIRMAE/centros.csv )
	if [ -z "$lineaCentros" ]
	then
		#Si no existe el centro, el registro no es valido.
		#Loggearlo
		#Grabar registro rechazado
		$log_command "procep" "Centro inexistente" "ERR" "0"
		touch $pathRechazado
		echo "$nombreArchivo;centro inexistente;$linea;$USER;$(fecha)">>$pathRechazado
		((cantidadRechazados++))
		continue
	fi

	#Extraccion de campos del centro
	IFS=";" read -ra CAMPOS_CENTRO <<< "$lineaCentros"
	NOMBRE_CENTRO=${CAMPOS_CENTRO[1]}
	#echo "Nombre centro del maestro: $NOMBRE_CENTRO"


	#************************************
	#	Validacion de Actividad     *
	#************************************
	lineaActividades=$( grep "$actividad" $GRUPO/$DIRMAE/actividades.csv )
	if [ -z "$lineaActividades" ]
	then
		#Si no existe la actividad, el registro no es valido.
		$log_command "procep" "Actividad inexistente" "ERR" "0"
		#Grabar registro rechazado
		touch $pathRechazado
		echo "$nombreArchivo;actividad inexistente;$linea;$USER;$(fecha)">>$pathRechazado
		((cantidadRechazados++))
		continue
	fi

	#Extraccion de campos de actividad
	IFS=";" read -ra CAMPOS_ACTIVIDAD <<< "$lineaActividades"
	CODIGO_ACTIVIDAD=${CAMPOS_ACTIVIDAD[0]}
	CODIGO_PROVINCIA=${CODIGO_ACTIVIDAD:5}
	#echo "Codigo provincia: $CODIGO_PROVINCIA"

	#Extraccion del nombre de la provincia que realiza la actividad mediante su codigo.
	lineaProvincias=$( grep "^$CODIGO_PROVINCIA;" $GRUPO/$DIRMAE/provincias.csv )
	#echo "Linea provincias: $lineaProvincias"
	IFS=";" read -ra CAMPOS_PROVINCIA <<< "$lineaProvincias"
	NOMBRE_PROVINCIA=${CAMPOS_PROVINCIA[1]}

	#*************************************
	#	Validacion de Trimestre      *
	#*************************************
	lineaTrimestres=$( grep "$trimestre" $GRUPO/$DIRMAE/trimestres.csv )
	#echo "Linea trimestres: $lineaTrimestres"
	if [ -z "$lineaTrimestres" ]
	then
		#Si no existe el trimestre, el registro no es valido.
		$log_command "procep" "Trimestre inexistente" "ERR" "0"
		#Grabar registro rechazado
		touch $pathRechazado
		#touch "$GRUPO/$DIRPROC/rechazado-2016"
		echo "$nombreArchivo;Trimestre inválido: nombre inexistente;$linea;$USER;$(fecha)">>$pathrechazado
		((cantidadRechazados++))
		continue
	fi

	#Extraccion de campos del trimestre
	IFS=";" read -ra CAMPOS_TRIMESTRE <<< "$lineaTrimestres"
	anioTrimestre=${CAMPOS_TRIMESTRE[0]}
	nombreTrimestre=${CAMPOS_TRIMESTRE[1]}
	FDESDE_TRI=${CAMPOS_TRIMESTRE[2]}
	FHASTA_TRI=${CAMPOS_TRIMESTRE[3]}

	#echo "Nombre trimestre: $nombreTrimestre"
	#echo "Año trimestre: $anioTrimestre"
    anioCorriente=$($DATE +"%Y")
	if [ "$anioTrimestre" == "$anioCorriente" ]
	then
		#echo "Año igual al año corriente"

		#*********************************
		#	Validacion de fecha      *
		#*********************************

		#Extraccion de fecha del nombre del archivo
		IFS="_" read -ra CAMPOS_ARCHIVO <<< "$nombreArchivo"
		fechaArchivo=${CAMPOS_ARCHIVO[3]}
		if [ $fecha -le "${fechaArchivo:0:8}" -o $fecha -eq "${fechaArchivo:0:8}" ]
		then
			#Validacion de rango de fecha
			if [ $(fechaEntre $fecha $FDESDE_TRI $FHASTA_TRI) -ne 1 ]
			then
				$log_command "procep" "La fecha no se corresponde con el trimestre indicado" "ERR" "0"
				#Grabar registro rechazado
				touch $pathRechazado
				echo "$nombreArchivo;La fecha no se corresponde con el trimestre indicado;$linea;$USER;$(fecha)">>$pathRechazado
			fi
		else
			$log_command "procep" "Fecha invalida" "ERR" "0"
		    	#Grabar registro rechazado
			touch $pathRechazado
			echo "$nombreArchivo;Fecha invalida;$linea;$USER;$(fecha)">>$pathRechazado
		fi
	else
		#Si el año no es correcto, el registro no es valido
		$log_command "procep" "Año incorrecto" "ERR" "0"

		#Grabar registro rechazado
		touch $pathRechazado
		echo "$nombreArchivo;Trimestre inválido: trimestre no es del año presupuestario corriente;$linea;$USER;$(fecha)">>$pathRechazado
		((cantidadRechazados++))
		continue
	fi


	#********************************
	#	Validacion de Gasto     *
	#********************************
    if (( $(echo "$gasto 0" | awk '{print ($1 < $2)}') ))
	then
		$log_command "procep" "El gasto debe ser mayor a cero." "ERR" "0"
		touch $pathRechazado
		echo "$nombreArchivo;importe invalido;$linea;$USER;$(fecha)">>$pathRechazado
		((cantidadRechazados++))
		continue
	fi

	#Si el registro paso las validaciones, lo grabo como aceptado.
	touch $pathAceptado
	echo "$id;$fecha;$centro;$actividad;$trimestre;$gasto;$nombreArchivo;$CODIGO_ACTIVIDAD;$NOMBRE_PROVINCIA;$NOMBRE_CENTRO">>$pathAceptado

	((cantidadAceptados++))
done <$GRUPO/$DIROK/$archivo
$log_command "procep" "Cantidad de registros leidos: $cantidadLeidos" "INFO" "0"
$log_command "procep" "Cantidad de registros validados correctamente: $cantidadAceptados" "INFO" "0"
$log_command "procep" "Cantidad de registros rechazados $cantidadRechazados" "INFO" "0"
}

if [ ! checkenv ]
then
	echo "Ambiente no inicializado"
	exit 1
fi

cantidadArchivos=$(ls $GRUPO/$DIROK | wc -l)

$log_command "procep" "Cantidad de archivos a procesar: $cantidadArchivos" "INFO" "0"

listaArchivos=$(ls $GRUPO/$DIROK)

for archivo in $listaArchivos
do
	#Verificacion de archivo duplicado.
	if [ -f $GRUPO/$DIRPROC/proc/$archivo ]
	then
		$log_command "procep" "Archivo Duplicado. Se rechaza el archivo $archivo" "INFO" "0"
		#mv $GRUPO/$DIROK/$archivo $GRUPO/$DIRNOK
		$GRUPO/$DIRBIN/movep.sh $GRUPO/$DIROK/$archivo $GRUPO/$DIRNOK "procep"
	else
		#Verificacion de formato
		linea=$(sed -n '2p' $GRUPO/$DIROK/$archivo)
		regex='^([^;]+;){5}[^;]+$'
		if [[ "$linea" =~ $regex ]]
		then
			#Validacion de campos
			$log_command "procep" "Archivo a procesar $archivo" "INFO" "0"
			validarRegistros $archivo

			#Se mueve el archivo para evitar su reprocesamiento
			#mv $GRUPO/$DIROK/$archivo $GRUPO/$DIRPROC/proc
			$GRUPO/$DIRBIN/movep.sh $GRUPO/$DIROK/$archivo $GRUPO/$DIRPROC/proc "procep"
		else
			$log_command "procep" "Estructura inesperada. Se rechaza el archivo $archivo." "INFO" "0"
			#mv $GRUPO/$DIROK/$archivo $GRUPO/$DIRNOK
			$GRUPO/$DIRBIN/movep.sh $GRUPO/$DIROK/$archivo $GRUPO/$DIRNOK "procep"
		fi
	fi
done

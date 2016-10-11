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
			while read -r linea
			do
				#Validacion Centro de Presupuestos
				centro=$( echo $linea | cut -d";" -f3 )
				while read -r lineaCentros
				do
					centroValido=$( echo $lineaCentros | cut -d';' -f1 )
					if [ $centro == $centroValido ]
					then
						echo "centro valido"
					fi
				done <$GRUPO/$DIRMAE/centros.csv

				#Validacion de Actividad
				actividad=$( echo $linea | cut -d';' -f4 )
				echo $actividad
				while read -r lineaActividades
				do
					actividadValida=$( echo $lineaActividades | cut -d';' -f4 )
					#echo $actividadValida
					if [ "$actividad" == "$actividadValida" ]
					then
						echo "actividad valida"
					fi
				done <$GRUPO/$DIRMAE/actividades.csv

				#Validacion de Trimestre
				trimestre=$( echo $linea | cut -d';' -f5 )
				echo $trimestre
				while read -r lineaTrimestres
				do
					trimestreValido=$( echo $lineaTrimestres | cut -d';' -f2 )
					if [ "$trimestre" == "$trimestreValido" ]
					then
						#Validacion año presupuestario corriente.
						anioTrimestre=$( echo $lineaTrimestres | cut -d';' -f1 )
						anioCorriente="2016"
						if [ "$anioTrimestre" == "$anioCorriente" ]
						then	
							#Validacion de Fecha
							fecha=$( echo $linea | cut -d';' -f2 )
							echo $fecha
							FDESDE_TRI=$( echo $lineaTrimestres | cut -d';' -f3 )
							FHASTA_TRI=$( echo $lineaTrimestres | cut -d';' -f4 )
							#Verificar rango de fecha
							echo "trimestre valido"
						else
							echo "trimestre invalido"
						fi
					fi
				done <$GRUPO/$DIRMAE/trimestres.csv

				#Validacion de Gasto
				gasto=$( echo $linea | cut -d';' -f6 )
				if [ $gasto > 0 ]
				then
					echo "Gasto permitido"
				else
					echo "El gasto debe ser mayor a cero."
				fi

			done <$GRUPO/$DIRREC/$archivo
		else
			$ARCHLOGGER "procep" "Estructura inesperada. Se rechaza el archivo $archivo." "INFO" "1"
			#mv $GRUPO/$DIRREC/$archivo $GRUPO/$DIRNOK
		fi
	fi
done

# tpsisop - EPLAM

Archivos y carpetas

  - __mae: Archivos maestros y tablas entregados por la catedra.
  - __nov: Archivos de novedades entregados por la catedra.
  - __scripts: Comandos del sistema EPLAM.
  - instalep.sh: Instalador del sistema EPLAM.
  - empaquetar.sh: Genera el paquete de instalacion en formato .tgz
  - README: Pasos para descarga, instalacion y manejo del sistema.


## Instalación

La instalación se realiza con los siguientes pasos:

```bash
# Se descomprime el instalador del sistema
tar xzvf tp1sisop.tgz
# La descompresión genera la carpeta EPLAM
cd EPLAM
# Corremos el instalador
./instalep.sh
```

El script de instalación hará una serie de preguntas para customizar la
instalación, tales como los directorios de archivos para logs o para los
archivos nuevos a procesar.

## Inicialización

Se realiza utilizando el script `initep.sh`
Es el segundo script a correr luego de instalep.sh.
Se tiene que correr de la siguiente manera:

```
# Se puede usar source o .
source ./Grupo8/directorio_bin/initep.sh ./Grupo8/directorio_conf/instalep.conf
```

Donde el `directorio_bin` es el directorio definido como el que va a contener
los ejecutables durante la instalación y el `instalep.conf` es el archivo de
configuración generado por el instalador (se encuentra en el directorio
`directorio_conf`, también definido durante la instalación).


El source es necesario para setear las variables de entorno. Se le tiene que
pasar la ruta al archivo de configuración, creado por instalep.sh, como parametro.


### empaquetar.sh

Genera el entragable en formato .tgz
Sino funciona darle permisos 775
Agregar en el script los archivos que se desean comprimir en el entregable

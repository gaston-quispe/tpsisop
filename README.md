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
# Posicionarse en la carpeta descomprimida
cd EPLAM
# Corremos el instalador
./instalep.sh <archivo logger>
```

<archivo logger> es la ubicación del script `logep.sh`.
Antes de completar la instalación, el logger se encuentra en:
**__scripts/logep.sh**
El script de instalación hará una serie de preguntas para customizar la
instalación, tales como los directorios de archivos para logs o para los
archivos nuevos a procesar.
Puede optarse por la opción default presionando enter.
Luego de ser completada exitosamente la instalacion, el logger podrá 
encontrarse en:
**<directorio de binarios>/logep.sh**

## Inicialización

Se realiza utilizando el script `initep.sh`
Es el segundo script a correr luego de instalep.sh.
Se tiene que correr de la siguiente manera:

```
# Se puede usar source o .
source ./Grupo8/directorio_bin/initep.sh ./Grupo8/dirconf/instalep.conf
```

Donde el `directorio_bin` es el directorio definido como el que va a contener
los ejecutables durante la instalación y el `instalep.conf` es el archivo de
configuración generado por el instalador.
Por default, `directorio_bin` es 'bin'.

El source es necesario para setear las variables de entorno. Se le tiene que
pasar la ruta al archivo de configuración, creado por instalep.sh, como parametro.

### Inicializacion de demonio
Al correr el script `initep.sh`, al final de la inicializacion se le da al usuario
la posibilidad de inicializar el demonio.
En caso de no querer hacerlo automaticamente, se puede optar por hacerlo manualmente
ejecuntando:
```bash
./demonep.sh &
```

En ambos casos se imprimira por la salida estandar el proceso sobre el cual el demonio
se esta ejecutando. Para acabar el proceso (matar el demonio) se debe correr el 
siguiente comando:
```bash
kill <proceso ID>
```

Donde <proceso ID> es el numero del proceso que se imprimio por pantalla. En caso de no
conocerlo, se puede hacer uso del comando `ps` para conocer los procesos activos y tomar
el valor de PID del `demonep.sh`
 
### empaquetar.sh

Genera el entragable en formato .tgz
Sino funciona darle permisos 775
Agregar en el script los archivos que se desean comprimir en el entregable

# tpsisop - EPLAM

Archivos y carpetas

  - __mae: Archivos maestros y tablas entregados por la catedra.
  - __nov: Archivos de novedades entregados por la catedra.
  - __scripts: Comandos del sistema EPLAM.
  - instalep.sh: Instalador del sistema EPLAM.
  - empaquetar.sh: Genera el paquete de instalacion en formato .tgz
  - README: Pasos para descarga, instalacion y manejo del sistema.


### initep.sh

Es el segundo script a correr luego de instalep.sh.
Se tiene que correr de la siguiente manera:

```
# Se puede usar source o .
source ./Grupo8/bin/initep.sh ./Grupo8/dirconf/instalep.conf
```

El source es necesario para setear las variables de entorno. Se le tiene que
pasar la ruta al archivo de configuración, creado por instalep.sh, como parametro.


#Si no funciona dar al script permisos 775
mkdir EPLAM
cp -R __mae EPLAM
cp -R __nov EPLAM
cp -R __scripts EPLAM
cp instalep.sh EPLAM
cp README EPLAM
tar czvf tp1sisop.tgz EPLAM
rm -R EPLAM

#PARA DESEMPAQUETAR
#tar xzvf tp1sisop.tgz

# !/bin/bash
# Conexión a puerto serial debug 
# uso: . minicom.sh datenamefile.log

minicom -D /dev/ttyUSB0 -b 115200 -C $1

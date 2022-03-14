# Minicom session connected to TX2 serial debug
# to include timestamp Ctrl+A => Z => N:wq
# usage: . minicom.sh datenamefile.log

minicom -D /dev/ttyUSB0 -b 115200 -C $1

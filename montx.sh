#!/bin/bash
#############################################################
#
# file: montx.sh
#
# A. Serrano y S. Cuenca
#
# descripción:
#
#   - mon.sh lanza la ejecución del namebench N veces
#       * recoge via SSH: mensajes CPU (printf), mensajes error GPU
#       * detecta timeout si el bench no ha terminado
#           si la ejecución tarda más que el timeout => rebota el sistema power_off
#           si la ejecucion termina con código de error de la GPU (EXIT_FAILURE 1)
#               * registra el evento
#               * relanza la ejecución (sin hacer poweroff)
#
#   - namebench realiza RUNBLOCK ejecuciones antes de terminar,
#   enviando mensajes de error y un testcheck al final
#
#   parametros:
#   - t_timeout: tiempo estimado de ejecución del bench (RUNBLOCK) x2
#   - n_ejecuciones: número de ejecuciones del bench
#
#   usage: . montx.sh namebench
#
##############################################################
#
#   Previos:
#   A) configurar ssh de para que Jetson no pida contraseña
#       1. Genera clave para Raspi: pi@hostname$ ssh-keygen  (sólo se hace una vez)
#       2. Copia la clave en la Jetson: ssh-copy-id -i ~/.ssh/id_rsa.pub jetson@ip
#   B) configurar IP estática (por si acaso)
#  /etc/dhcpcd.conf
#
#   Problema:
#   parece que los mensajes no se envían hasta el final de la ejecución del bench
#
#
#
###############################################################

# path en SUT (Jetson)
BINDIR=/home/sergio/202203_CNA_tests/TX2_benchmarks/$1
BINDIR2=/home/sergio/202203_CNA_tests/TX2_benchmarks/
#now=$(date +%Y%m%d_%H_%M_%S_)
NAMEBENCH=$1
now=$(date +%Y%m%d_%H_%M_%S_)
# path en CC (Raspi)
DIRLOG=/home/pi/202203_CNA_tests/TX2_Results
#echo "$BINDIR"
estado=0
#boot_counter=0
i=0

echo "202203 INICIANDO TEST" | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv

echo "RESET_ON"
python3 rele_on.py
sleep 3
echo "RESET_OFF"
python3 rele_off.py
sleep 25  # esperamos a que arranque linux y se asigne IP


echo $1

for (( ; ; )) #for (( i=0; i<100; i++ ))    # Esto debe ser for (( ; ; )) corre para siempre
do
    if [[ $estado -eq 75 ]] # hay que rebotar
    then
        now=$(date +%Y%m%d_%H_%M_%S_)
        echo "Reboot tras HANG" | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv
        echo "RESET_ON"
                python3 rele_on.py
                sleep 3
                echo "RESET_OFF"
                python3 rele_off.py
                sleep 25  # esperamos a que arranque linux y se asigne IP
    fi

        echo "B_RUN=$i"
    #  timeout -k A B runs the command for A seconds, and if it is not terminated, it will kill it after B seconds
    #  timeout --preserve-status returns 124 when the time limit is reached. Otherwise, it returns the exit status of the managed command.

# MMult UNHARD 1024
#timeout --preserve-status -s 9 -k 60s 60s ssh sergio@192.168.1.132 -p 22 $BINDIR/bin/$NAMEBENCH -s 1024 -x 32 -y 32 -r 80 -b 0 -k 1 -g 0 | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv

# MMult UNHARD 2048
#timeout --preserve-status -s 9 -k 60s 60s ssh sergio@192.168.1.132 -p 22 $BINDIR/bin/$NAMEBENCH -s 2048 -x 32 -y 32 -r 20 -b 0 -k 1 -g 0 | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv

# MMult UNHARD 3072
#timeout --preserve-status -s 9 -k 25s 25s ssh sergio@192.168.1.132 -p 22 $BINDIR/bin/$NAMEBENCH -s 3072 -x 32 -y 32 -r 3 -b 0 -k 1 -g 0 | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv


# MMult REDUNDANT 1024
#timeout --preserve-status -s 9 -k 60s 60s ssh sergio@192.168.1.132 -p 22 $BINDIR2/mmult/bin/$NAMEBENCH -s 1024 -x 32 -y 32 -r 80 -b 1 -k 1 -g 0 | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv

# MMult REDUNDANT 2048
#timeout --preserve-status -s 9 -k 25s 25s ssh sergio@192.168.1.132 -p 22 $BINDIR2/mmult/bin/$NAMEBENCH -s 2048 -x 32 -y 32 -r 10 -b 1 -k 1 -g 0 | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv

# MMult REDUNDANT 3072
#timeout --preserve-status -s 9 -k 25s 25s ssh sergio@192.168.1.132 -p 22 $BINDIR2/mmult/bin/$NAMEBENCH -s 3072 -x 32 -y 32 -r 3 -b 1 -k 1 -g 0 | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv


# Modo nn UNHARD heavy 
timeout --preserve-status -s 9 -k 25s 25s ssh sergio@172.19.33.156 -p 22 $BINDIR/bin/$NAMEBENCH filelist_64 -r 1000 -lat 30 -q 1 -w 1 -f 1 -s 1 -a 1 -k 10000 -g 0 -b 4| ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv

# Modo nn_redundant friendly
#timeout --preserve-status -s 9 -k 25s 25s ssh sergio@172.19.33.156 -p 22 $BINDIR2/nn/bin/$NAMEBENCH filelist_64 -r 1000 -lat 30 -q 1 -w 850 -f 1 -s 850 -a 1 -k 10000 -g 0 -b 2| ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv

# Modo nn_redundant heavy
#timeout --preserve-status -s 9 -k 25s 25s ssh sergio@172.19.33.156 -p 22 $BINDIR2/nn/bin/$NAMEBENCH filelist_64 -r 1000 -lat 30 -q 1 -w 1 -f 1 -s 1 -a 1 -k 10000 -g 0 -b 3| ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv
	
	estado=$?  # recuperamos lo que retorna timeout
    echo "$estado"
    ((i=i+1))
	
	if [[ $estado -ne 0 ]]
    then
        if [[ $estado -eq 1 ]] # EXIT_FAILURE
        then
            echo "ERROR en GPU" | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv
        else  #hang
            # if [[ $estado -eq 137 ]] # workaround
            # then
               # echo "CONTINUE verificar si es crítico"
            # else
                echo "posible HANG" | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv
                estado=75
                #((boot_counter=boot_counter+1))
            #fi
        fi
    fi
	
	## No funciona bien porque ssh devuelve también 0 algunas veces y se interpreta como hang
	
    # if [[ $estado -ne 65 ]]
    # then
        # if [[ $estado -eq 1 ]] # EXIT_FAILURE
        # then
            # echo "ERROR en GPU" | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv
			 # estado=75
        # else  #hang
            # if [[ $estado -eq 0 ]] # workaround
             # then
                # echo "posible error conexión" | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv
                # estado=75
            # fi
			# if [[ $estado -eq 137 ]] # workaround
             # then
                # echo "posible HANG" | ts "%Y%m%d_%H_%M_%S:" >> $DIRLOG/$now$NAMEBENCH.csv
                # estado=75
            # fi

        # fi
    # fi
	

done



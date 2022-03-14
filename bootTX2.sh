# !bin/bash/
# reboot the TX2 using the resetn pin
# Linux is up and running after 16s aprox. after rele_off
# usage: . reboottx2.sh
# 

python3 rele_on.py
sleep 3
python3 rele_off.py
sleep 3


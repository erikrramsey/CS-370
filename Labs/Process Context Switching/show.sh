if [ "$1" == "cpu-print" ]; then
    ./cpu
    USRTIME=`echo "scale=2; $(cat /proc/$PID/stat | cut -d' ' -f14) / $(getconf CLK_TCK)" | bc`
    echo ${USRTIME}
elif [ "$1" == "cpu" ]; then
    ./cpu
else
    echo Error, invalid parameter.
fi
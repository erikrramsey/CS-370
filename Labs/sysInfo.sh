if [ "$1" == "sys" ]; then

    idDir="/sys/class/dmi/id/"
    hn="$(hostname)"
    ut="$(uptime | awk '{print $3}' | sed 's/,//')"
    manu="$(cat ${idDir}chassis_vendor)"
    pn="$(cat ${idDir}product_family | awk '{print $1}')"
    vers="$(cat ${idDir}product_family | awk '{print $2}')"
    mt="$(lscpu | grep Hypervisor | wc -l)"
    if [ $mt -gt 0 ]; then 
        mt="VM"; else 
        mt="Physical"; 
    fi
    os="$(uname)"
    kernel="$(uname -r)"
    arch="$(arch)"
    proc="$(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//')"
    au="$(w | awk 'FNR == 3 {print $1}')"
    msip="$(ip a | awk '/inet 192/ {print $2}')"

    echo -------------------------------System Information----------------------------
    echo "Hostname:             ${hn}"
    echo "uptime:               ${ut}"
    echo "Manufacturer:         ${manu}"
    echo "Product Name:         ${pn}"
    echo "Version:              ${vers}"
    echo "Machine Type:         ${mt}"
    echo "Operating System:     ${os}"
    echo "Kernel:               ${kernel}"
    echo "Architecture:         ${arch}"
    echo "Processor Name:       ${proc}"
    echo "Active User:          ${au}"
    echo "Main System IP:       ${msip}"

elif [ "$1" == "mem" ]; then
    cpuUsage="$(cat /proc/stat | awk '/cpu/{printf("%.2f%%\n"), ($2+$4)*100/($2+$4+$5)}' | awk '{print $0}' | head -1)"

    echo total used free shared buff/cache available 
    echo -------------------------------CPU/Memory Usage------------------------------
    echo "$(free | awk 'FNR > 1 {print $1 " "  $2 " " $3 " " $4 " " $5 " " $6 " " $7}')"
    echo
    echo "Memory Usage:         $(free | awk 'FNR == 2 {printf("%.2f%%\n"), ($3 / $2 * 100)}')"
    echo "Swap Usage:           $(swapon -s | awk 'FNR == 2 {printf("%.2f%%\n"), ($4 / $3 * 100 "%")}')"
    echo "Cpu Usage:            ${cpuUsage}"
elif [ "$1" == "disk" ]; then
    echo -------------------------------Disk Usage-------------------------------
    echo "$(df -h | awk '$NF=="/"{printf "Disk Usage: %s\t\t\n\n", $5}')"
    echo Filesystem Size Used Avail Use Mounted on
    echo "$(df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}')"
elif [ "$1" == "" ]; then
    echo "Usage: sysInfo <sys|mem|disk>"
else
    echo Error, invalid parameter.
fi
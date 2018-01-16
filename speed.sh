#!/usr/bin/env bash
#
# Description: Auto test download & I/O speed script
#
# Copyright (C) 2015 - 2016 Teddysun <i@teddysun.com>
#
# Thanks: 
#
# 
# URL: http://www.cnbanwagong.com/ add Vultr 15 Download test
#

if  [ ! -e '/usr/bin/wget' ]; then
    echo "Error: wget command not found. You must be install wget command at first."
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

speed_test() {
    local speedtest=$(wget -4O /dev/null -T300 $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
    local ipaddress=$(ping -c1 -n `awk -F'/' '{print $3}' <<< $1` | awk -F'[()]' '{print $2;exit}')
    local nodeName=$2
    printf "${YELLOW}%-32s${GREEN}%-24s${RED}%-14s${PLAIN}\n" "${nodeName}" "${ipaddress}" "${speedtest}"
}

speed() {
    speed_test 'http://cachefly.cachefly.net/100mb.test' 'CacheFly'
    speed_test 'http://speedtest.tokyo.linode.com/100MB-tokyo.bin' 'Linode, Tokyo, JP'
    speed_test 'http://speedtest.singapore.linode.com/100MB-singapore.bin' 'Linode, Singapore, SG'
    speed_test 'http://speedtest.london.linode.com/100MB-london.bin' 'Linode, London, UK'
    speed_test 'http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin' 'Linode, Frankfurt, DE'
    speed_test 'http://speedtest.fremont.linode.com/100MB-fremont.bin' 'Linode, Fremont, CA'
    speed_test 'http://speedtest.dal05.softlayer.com/downloads/test100.zip' 'Softlayer, Dallas, TX'
    speed_test 'http://speedtest.sea01.softlayer.com/downloads/test100.zip' 'Softlayer, Seattle, WA'
    speed_test 'http://speedtest.fra02.softlayer.com/downloads/test100.zip' 'Softlayer, Frankfurt, DE'
    speed_test 'http://speedtest.hkg02.softlayer.com/downloads/test100.zip' 'Softlayer, HongKong, CN'
    speed_test 'http://speedtest-nyc1.digitalocean.com/100mb.test' 'digitalocean,NYC1'
    speed_test 'http://speedtest-ams2.digitalocean.com/100mb.test' 'digitalocean,AMS2'
    speed_test 'http://speedtest-sfo1.digitalocean.com/100mb.test' 'digitalocean,SFO1'
    speed_test 'http://speedtest-sgp1.digitalocean.com/100mb.test' 'digitalocean,SGP1'
    speed_test 'http://speedtest-lon1.digitalocean.com/100mb.test' 'digitalocean,LON1'
    speed_test 'http://speedtest-fra1.digitalocean.com/100mb.test' 'digitalocean,FRA1'
    speed_test 'http://speedtest-tor1.digitalocean.com/100mb.test' 'digitalocean,TOR1'
    speed_test 'http://speedtest-blr1.digitalocean.com/100mb.test' 'digitalocean,BLR1'
    speed_test 'https://fra-de-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Frankfurt, DE'
    speed_test 'https://par-fr-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Paris, France'
    speed_test 'https://ams-nl-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Amsterdam, NL'
    speed_test 'https://lon-gb-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,London, UK'
    speed_test 'https://sgp-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Singapore'
    speed_test 'https://nj-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,New York (NJ)'
    speed_test 'https://hnd-jp-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Tokyo, Japan'
    speed_test 'https://il-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Chicago, Illinois'
    speed_test 'https://fl-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Miami, Florida '
    speed_test 'https://wa-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Seattle, Washington'
    speed_test 'https://tx-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Dallas, Texas'
    speed_test 'https://sjo-ca-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Silicon Valley, California'
    speed_test 'https://lax-ca-us-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Los Angeles, California'
    speed_test 'https://syd-au-ping.vultr.com/vultr.com.100MB.bin' 'Vultr,Sydney, Australia'
}

io_test() {
    (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}

cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
tram=$( free -m | awk '/Mem/ {print $2}' )
uram=$( free -m | awk '/Mem/ {print $3}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
uswap=$( free -m | awk '/Swap/ {print $3}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )
ipv6=$( wget -qO- -t1 -T2 ipv6.icanhazip.com )
disk_size1=($( LANG=C df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
disk_size2=($( LANG=C df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
disk_total_size=$( calc_disk ${disk_size1[@]} )
disk_used_size=$( calc_disk ${disk_size2[@]} )

clear
next
echo "CPU model            : $cname"
echo "Number of cores      : $cores"
echo "CPU frequency        : $freq MHz"
echo "Total size of Disk   : $disk_total_size GB ($disk_used_size GB Used)"
echo "Total amount of Mem  : $tram MB ($uram MB Used)"
echo "Total amount of Swap : $swap MB ($uswap MB Used)"
echo "System uptime        : $up"
echo "Load average         : $load"
echo "OS                   : $opsy"
echo "Arch                 : $arch ($lbit Bit)"
echo "Kernel               : $kern"
next
io1=$( io_test )
echo "I/O speed(1st run)   : $io1"
io2=$( io_test )
echo "I/O speed(2nd run)   : $io2"
io3=$( io_test )
echo "I/O speed(3rd run)   : $io3"
ioraw1=$( echo $io1 | awk 'NR==1 {print $1}' )
[ "`echo $io1 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw1=$( awk 'BEGIN{print '$ioraw1' * 1024}' )
ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
[ "`echo $io2 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw2=$( awk 'BEGIN{print '$ioraw2' * 1024}' )
ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
[ "`echo $io3 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw3=$( awk 'BEGIN{print '$ioraw3' * 1024}' )
ioall=$( awk 'BEGIN{print '$ioraw1' + '$ioraw2' + '$ioraw3'}' )
ioavg=$( awk 'BEGIN{printf "%.1f", '$ioall' / 3}' )
echo "Average I/O speed    : $ioavg MB/s"
next
printf "%-32s%-24s%-14s\n" "Node Name" "IPv4 address" "Download Speed"
speed && next

vi cm_safe_scan.sh
i
#!/bin/bash

# Author:   DuoyiChen、鬼魅羊羔、秋水逸冰
# Email:    duoyichen@qq.com
# Date:     20180531 06:50
# Version:  1


date=$(date +%Y%m%d%H%M%S)
file_log=${PWD}/cm_safe_scan_report.log
#file_md5=${PWD}/cm_safe_scan_report.log
tee_log=" |tee -a ${file_log}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
PLAIN='\033[0m'


echo -e "Scan on $date" > ${file_log}
echo -e "${RED}说明：本脚本只做检查的操作，不会对服务器做任何修改，管理员可以根据此报告进行相应的设置。${PLAIN}" |tee -a ${file_log}
echo -e "${RED}---------------- " Are You OK ? " ----------------${PLAIN}"
read key

rpms="curl wget"
install_rpms()
{
    is_yum=0
    counter=0
    while [ "${is_yum}" == "0" ] && [ "${counter}" != "5" ]
    do
        rpm -q epel-release
        if [ "$?" == "0" ];then
            is_yum=1
            continue
            echo -e "\n\033[32mepel-release has been installed already!\033[0m\n"
        else
            yum install -y epel-release
            if [ "$?" == "0" ];then
                is_yum=1
                echo -e "\n\033[32mInstall epel-release Successful!\033[0m\n"
            else
                let counter+=1
            fi
            
        fi
    done

    is_yum=0
    counter=0
    while [ "${is_yum}" == "0" ] && [ "${counter}" != "5" ]
    do
        yum clean all
        yum install -y ${rpms}
        is_yum=1
        let counter+=1

        for i in ${rpms}
        do
            rpm -q $i
            if [ "$?" == "0" ];then
                echo -e "\n\033[32m$i has installed already!\033[0m\n"
            else
                echo -e "\n\033[32m$i is not installed yet!\033[0m\n"
                is_yum=0
                break
            fi
        done
    done

    if [ "${counter}" == "5" ];then
        echo -e "\n\033[32mInstall RPMs error, Please check your Extnnal\047s network!\033[0m\n"
        exit 1
    else
        echo -e "\n\033[32mInstall RPMs Successful!\033[0m\n"
    fi
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}



echo -e "\n\n\n-------------------------------- 01 系统信息 --------------------------------\n" |tee -a ${file_log}

echo "本机的IP地址是：" |tee -a ${file_log}
ifconfig | grep --color "\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" |tee -a ${file_log}

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
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
disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
disk_total_size=$( calc_disk ${disk_size1[@]} )
disk_used_size=$( calc_disk ${disk_size2[@]} )

clear
next
echo -e "CPU model            : ${BLUE}$cname${PLAIN}"
echo -e "Number of cores      : ${BLUE}$cores${PLAIN}"
echo -e "CPU frequency        : ${BLUE}$freq MHz${PLAIN}"
echo -e "Total size of Disk   : ${BLUE}$disk_total_size GB ($disk_used_size GB Used)${PLAIN}"
echo -e "Total amount of Mem  : ${BLUE}$tram MB ($uram MB Used)${PLAIN}"
echo -e "Total amount of Swap : ${BLUE}$swap MB ($uswap MB Used)${PLAIN}"
echo -e "System uptime        : ${BLUE}$up${PLAIN}"
echo -e "Load average         : ${BLUE}$load${PLAIN}"
echo -e "OS Version           : ${BLUE}$opsy${PLAIN}"
echo -e "Arch                 : ${BLUE}$arch ($lbit Bit)${PLAIN}"
echo -e "Kernel               : ${BLUE}$kern${PLAIN}"
next

speed_test_v4() {
    local output=$(wget -4O /dev/null -T300 $1 2>&1)
    local speedtest=$(printf '%s' "$output" | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
    local ipaddress=$(printf '%s' "$output" | awk -F'|' '/Connecting to .*\|([^\|]+)\|/ {print $2}')
    local nodeName=$2
    printf "${YELLOW}%-32s${GREEN}%-24s${RED}%-14s${PLAIN}\n" "${nodeName}" "${ipaddress}" "${speedtest}"
}

speed_v4() {
    speed_test_v4 'http://cachefly.cachefly.net/100mb.test' 'CacheFly'
    speed_test_v4 'http://speedtest.tokyo.linode.com/100MB-tokyo.bin' 'Linode, Tokyo, JP'
    #speed_test_v4 'http://speedtest.singapore.linode.com/100MB-singapore.bin' 'Linode, Singapore, SG'
    #speed_test_v4 'http://speedtest.hkg02.softlayer.com/downloads/test100.zip' 'Softlayer, HongKong, CN'
}

printf "%-32s%-24s%-14s\n" "Node Name" "IPv4 address" "Download Speed"
speed_v4 && next



echo -e "\n\n\n-------------------------------- 02 账户权限 --------------------------------\n" |tee -a ${file_log}

awk -F":" '{if($2!~/^!|^*/){print "("$1")" " 是一个未被锁定的账户，请管理员检查是否需要锁定它或者删除它。"}}' /etc/shadow |tee -a ${file_log}
more /etc/login.defs | grep -E "PASS_MAX_DAYS" | grep -v "#" |awk -F' '  '{if($2!=90){print "/etc/login.defs里面的"$1 "设置的是"$2"天，请管理员改成90天。"}}' |tee -a ${file_log}
more /etc/login.defs | grep -E "PASS_MIN_LEN" | grep -v "#" |awk -F' '  '{if($2!=6){print "/etc/login.defs里面的"$1 "设置的是"$2"个字符，请管理员改成6个字符。"}}' |tee -a ${file_log}
more /etc/login.defs | grep -E "PASS_WARN_AGE" | grep -v "#" |awk -F' '  '{if($2!=10){print "/etc/login.defs里面的"$1 "设置的是"$2"天，请管理员将口令到期警告天数改成10天。"}}' |tee -a ${file_log}
grep TMOUT /etc/profile /etc/bashrc > /dev/null|| echo "未设置登录超时限制，请设置之，设置方法：在/etc/profile或者/etc/bashrc里面添加TMOUT=600参数" |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看系统密码文件修改时间" |tee -a ${file_log}
ls -ltr /etc/passwd |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看passwd文件中有哪些特权用户" |tee -a ${file_log}
awk -F: '$3==0 {print $1}' /etc/passwd |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看系统中是否存在空口令账户，不适用于Ubuntu系统" |tee -a ${file_log}
awk -F: '($2=="!!") {print $1}' /etc/shadow |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看系统中存在哪些非系统默认用户" |tee -a ${file_log}
echo "root:x:“该值大于500为新创建用户，小于或等于500为系统初始用户”" |tee -a ${file_log}
more /etc/passwd |awk -F ":" '{if($3>500){print "/etc/passwd里面的"$1 "的值为"$3"，请管理员确认该账户是否正常。"}}' |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看shell是否设置超时锁定策略" |tee -a ${file_log}
if more /etc/profile | grep -E "TIMEOUT= "; then
    echo  "系统设置了超时锁定策略 " |tee -a ${file_log}
else
    echo  "未 设置超时锁定策略 " |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo "#确保root用户的系统路径中不包含父目录，在非必要的情况下，不应包含组权限为777的目录" |tee -a ${file_log}
echo "check the Path set for root,make sure the path for root dont have father directory and 777 rights"
echo $PATH | egrep '(^|:)(\.|:|$)' |tee -a ${file_log}
find `echo $PATH | tr ':' ' '` -type d \( -perm -002 -o -perm -020 \) -ls |tee -a ${file_log}

echo "#检查操作系统Linux远程连接"
find  / -name  .netrc
find  / -name  .rhosts

echo "检查操作系统Linux用户umask设置"
for i in /etc/profile /etc/csh.login /etc/csh.cshrc /etc/bashrc
do
    grep -H umask $i|grep -v "#"
done





echo -e "\n\n\n-------------------------------- 03 系统命令与日志 --------------------------------\n" |tee -a ${file_log}

echo "检查系统中关键文件修改时间" |tee -a ${file_log}
echo "ls文件：是存储ls命令的功能函数，被删除以后，就无法执行ls命令，黑客可利用篡改ls文件来执行后门或其他程序。
login文件：login是控制用户登录的文件，一旦被篡改或删除，系统将无法切换用户或登陆用户
user/bin/passwd：是一个命令，可以为用户添加、更改密码，但是，用户的密码并不保存在/etc/passwd当中，而是保存在了/etc/shadow当中
etc/passwd：一个文件，主要是保存用户信息。
/sbin/portmap：是文件转换服务，缺少该文件后，无法使用磁盘挂载、转换类型等功能。
/bin/ps：进程查看命令功能支持文件，文件损坏或被更改后，无法正常使用ps命令。
/usr/bin/top：top命令支持文件，是Linux下常用的性能分析工具,能够实时显示系统中各个进程的资源占用状况。
/etc/shadow：是 /etc/passwd 的影子文件，密码存放在该文件当中，并且只有root用户可读。"

file_sys_list="/bin/ls
/bin/login
/bin/ps
/usr/bin/passwd
/usr/bin/top
/sbin/portmap
/etc/passwd
/etc/shadow
/etc/group"
ls -ltr ${file_sys_list}|awk '{print "文件名："$9"  ""最后修改时间："$6" "$7}' |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "检查系统文件完整性2(MD5检查)" |tee -a ${file_log}
echo "该项会获取部分关键文件的MD5值并入库，默认保存在 "$file_sys_md5" 中"
echo "如果第一次执行，则会提示md5sum: /sbin/portmap: 没有那个文件或目录"
echo "第二次重复检查时，则会对MD5DB中的MD5值进行匹配，来判断文件是否被更改过"

file_sys_md5="${PWD}/file_sys_md5"

if [ ! -f "$file_sys_md5" ];then
    echo -e "# $date" > "$file_sys_md5" |tee -a ${file_log}
fi

for i in $file_sys_list
do
    m=$(grep $i $file_sys_md5|awk '{print $2}')
    if [ "$m" == "" ]; then
        md5sum $i >> "$file_sys_md5"
    fi
done

md5sum -c "$file_sys_md5" 2>&1

echo -e "\n" |tee -a ${file_log}
echo -e "查看系统日志文件是否存在：\n" |tee -a ${file_log}
check_sys_log()
{
    if [ -e "$1" ]; then
        echo  "$1 日志文件 存在！" |tee -a ${file_log}
    else
        echo  "$1 日志文件 不存在！" |tee -a ${file_log}
    fi
}
file_log_sys_list="/var/log/audit/audit.log
/var/log/btmp
/var/log/lastlog
/var/log/messages
/var/log/secure
/var/log/syslog
/var/log/wtmp"
for i in $file_log_sys_list
do
	check_sys_log $i
done

echo -e "\n" |tee -a ${file_log}
echo "分析系统是否存在入侵行为：" |tee -a ${file_log}
more /var/log/secure |grep refused |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看正常情况下登录到本机的所有用户的历史记录：" |tee -a ${file_log}
last |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看系统启动记录：" |tee -a ${file_log}
last reboot |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "登录用户：" |tee -a ${file_log}
w $ |tee -a ${file_log}
who -a |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看history" |tee -a ${file_log}
history |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看计划任务" |tee -a ${file_log}
if service crond status | grep -E "listening on|active \(running\)"; then
    echo "crond服务 已 开启" |tee -a ${file_log}
    echo "计划任务如下：" |tee -a ${file_log}
    crontab -l |tee -a ${file_log}
    for u in `cat /etc/passwd | cut -d":" -f1`;do crontab -l -u $u |tee -a ${file_log};done
    cat /etc/crontab|egrep -v "^#|^$|SHELL=|PATH=|MAILTO=" |tee -a ${file_log}
    ls -l /var/spool/cron/ |tee -a ${file_log}
else
    echo "crond服务 未 开启" |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo "查看随机启动任务" |tee -a ${file_log}
cat /etc/rc.d/rc.local|egrep -v "^#|^$|touch /var/lock/subsys/local" |tee -a ${file_log}



echo -e "\n\n\n-------------------------------- 04 系统服务 --------------------------------\n" |tee -a ${file_log}

if ps -elf |grep xinet |grep -v "grep xinet";then
    echo "xinetd 服务正在运行，请检查是否可以把xinnetd服务关闭" |tee -a ${file_log}
else
    echo "xinetd 服务 未 开启" |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo  "查看是否开启了ssh服务" |tee -a ${file_log}
if service sshd status | grep -E "listening on|active \(running\)"; then
    echo "SSH服务 已 开启" |tee -a ${file_log}
else
    echo "SSH服务 未 开启" |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo "查看是否开启了telnet服务" |tee -a ${file_log}
if more /etc/xinetd.d/telnetd 2>&1|grep -E "disable=no"; then
    echo  "telnet服务 已 开启" |tee -a ${file_log}
else
    echo  "telnet服务 未 开启" |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo  "查看系统SSH远程访问设置策略(host.deny拒绝列表)" |tee -a ${file_log}
if more /etc/hosts.deny | grep -E "sshd: ";more /etc/hosts.deny | grep -E "sshd"; then
    echo  "远程访问策略 已 设置" |tee -a ${file_log}
else
    echo  "远程访问策略 未 设置" |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo  "查看系统SSH远程访问设置策略(hosts.allow允许列表)" |tee -a ${file_log}
if more /etc/hosts.allow | grep -E "sshd: ";more /etc/hosts.allow | grep -E "sshd"; then
    echo  "远程访问策略 已 设置" |tee -a ${file_log}
else
    echo  "远程访问策略 未 设置" |tee -a ${file_log}
fi
echo "当hosts.allow和 host.deny相冲突时，以hosts.allow设置为准。" |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看syslog日志审计服务是否开启" |tee -a ${file_log}
if service rsyslog status | egrep " active \(running";then
    echo "syslog服务 已 开启" |tee -a ${file_log}
else
    echo "syslog服务 未 开启，建议通过 service rsyslog start 开启日志审计功能" |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo "查看syslog日志是否开启外发" |tee -a ${file_log}
if more /etc/rsyslog.conf | egrep "@...\.|@..\.|@.\.|\*.\* @...\.|\*\.\* @..\.|\*\.\* @.\.";then
    echo "客户端syslog日志 已 开启外发" |tee -a ${file_log}
else
    echo "客户端syslog日志 未 开启外发" |tee -a ${file_log}
fi

echo -e "\n" |tee -a ${file_log}
echo "检查系统守护进程" |tee -a ${file_log}
more /etc/xinetd.d/rsync | grep -v "^#" |tee -a ${file_log}



echo -e "\n\n\n-------------------------------- 05 网络服务 --------------------------------\n" |tee -a ${file_log}

echo "查看系统中root用户外连情况" |tee -a ${file_log}
lsof -u root |egrep "ESTABLISHED|SYN_SENT|LISTENING" |tee -a ${file_log}
echo 状态解释
echo "ESTABLISHED：已建立连接，表示两台机器正在通信；"
echo "LISTENING：正在监听；"
echo "SYN_SENT：表示请求连接"

echo -e "\n" |tee -a ${file_log}
echo "查看系统中root用户TCP连接情况" |tee -a ${file_log}
lsof -u root |egrep "TCP" |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "检查网络连接和监听端口" |tee -a ${file_log}
netstat -an |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "路由表、网络连接、接口信息" |tee -a ${file_log}
netstat -rn |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看网卡详细信息" |tee -a ${file_log}
ifconfig -a |tee -a ${file_log}



echo -e "\n\n\n-------------------------------- 06 性能检查 --------------------------------\n" |tee -a ${file_log}

echo "CPU检查" |tee -a ${file_log}
dmesg | grep -i cpu |tee -a ${file_log}
#more /proc/cpuinfo

echo -e "\n" |tee -a ${file_log}
echo "内存状态检查" |tee -a ${file_log}
vmstat -wSm 3 9 |tee -a ${file_log}
more /proc/meminfo |tee -a ${file_log}
free -m |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "文件系统使用情况" |tee -a ${file_log}
df -h |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "网卡使用情况" |tee -a ${file_log}
lspci -tv |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "查看僵尸进程" |tee -a ${file_log}
ps -ef | grep zombie |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "耗CPU最多的进程" |tee -a ${file_log}
ps auxf |sort -nr -k 3 |head -5 |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
echo "耗内存最多的进程" |tee -a ${file_log}
ps auxf |sort -nr -k 4 |head -5 |tee -a ${file_log}

echo -e "\n" |tee -a ${file_log}
io_test() {
    (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

io1=$( io_test )
echo -e "I/O speed(1st run)   : ${YELLOW}$io1${PLAIN}" |tee -a ${file_log}

io2=$( io_test )
echo -e "I/O speed(2nd run)   : ${YELLOW}$io2${PLAIN}" |tee -a ${file_log}

io3=$( io_test )
echo -e "I/O speed(3rd run)   : ${YELLOW}$io3${PLAIN}" |tee -a ${file_log}

ioraw1=$( echo $io1 | awk 'NR==1 {print $1}' )
[ "`echo $io1 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw1=$( awk 'BEGIN{print '$ioraw1' * 1024}' )
ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
[ "`echo $io2 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw2=$( awk 'BEGIN{print '$ioraw2' * 1024}' )
ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
[ "`echo $io3 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw3=$( awk 'BEGIN{print '$ioraw3' * 1024}' )

ioall=$( awk 'BEGIN{print '$ioraw1' + '$ioraw2' + '$ioraw3'}' )
ioavg=$( awk 'BEGIN{printf "%.1f", '$ioall' / 3}' )
echo -e "Average I/O speed    : ${YELLOW}$ioavg MB/s${PLAIN}" |tee -a ${file_log}



echo -e "\n\n\n-------------------------------- 07 程序后门 --------------------------------\n" |tee -a ${file_log}

echo -e "\n检查 PHP 可疑程序：" |tee -a ${file_log}
if find / -type f -name *.php | xargs egrep -l "mysql_query\($query, $dbconn\)|专用网马|udf.dll|class PHPzip\{|ZIP压缩程序 荒野无灯修改版|$writabledb|AnonymousUserName|eval\(|Root_CSS\(\)|黑狼PHP木马|eval\(gzuncompress\(base64_decode|if\(empty\($_SESSION|$shellname|$work_dir |PHP木马|Array\("$filename"| eval\($_POST\[|class packdir|disk_total_space|wscript.shell|cmd.exe|shell.application|documents and settings|system32|serv-u|提权|phpspy|后门" 1>/dev/null 2>&1;then
    echo "检测到 PHP 可疑程序" |tee -a ${file_log}
    find / -type f -name *.php | xargs egrep -l "mysql_query\($query, $dbconn\)|专用网马|udf.dll|class PHPzip\{|ZIP压缩程序 荒野无灯修改版|$writabledb|AnonymousUserName|eval\(|Root_CSS\(\)|黑狼PHP木马|eval\(gzuncompress\(base64_decode|if\(empty\($_SESSION|$shellname|$work_dir |PHP木马|Array\("$filename"| eval\($_POST\[|class packdir|disk_total_space|wscript.shell|cmd.exe|shell.application|documents and settings|system32|serv-u|提权|phpspy|后门" |sort -n|uniq -c |sort -rn |tee -a ${file_log}
    find / -type f -name *.php | xargs egrep -l "mysql_query\($query, $dbconn\)|专用网马|udf.dll|class PHPzip\{|ZIP压缩程序 荒野无灯修改版|$writabledb|AnonymousUserName|eval\(|Root_CSS\(\)|黑狼PHP木马|eval\(gzuncompress\(base64_decode|if\(empty\($_SESSION|$shellname|$work_dir |PHP木马|Array\("$filename"| eval\($_POST\[|class packdir|disk_total_space|wscript.shell|cmd.exe|shell.application|documents and settings|system32|serv-u|提权|phpspy|后门" |sort -n|uniq -c |sort -rn |awk '{print $2}' | xargs -I{} cp {} /tmp/
    echo "可疑程序已拷贝到/tmp/目录" |tee -a ${file_log}
else
    echo "未检测到 PHP 可疑程序" |tee -a ${file_log}
fi

echo -e "\n检查 JSP 可疑程序：" |tee -a ${file_log}
if find / -type f -name *.jsp | xargs egrep -l "InputStreamReader\(this.is\)|W_SESSION_ATTRIBUTE|strFileManag|getHostAddress|wscript.shell|gethostbyname|cmd.exe|documents and settings|system32|serv-u|提权|jspspy|后门" 1>/dev/null 2>&1;then
    echo "发现 JSP 可疑程序" |tee -a ${file_log}
    find / -type f -name *.jsp | xargs egrep -l "InputStreamReader\(this.is\)|W_SESSION_ATTRIBUTE|strFileManag|getHostAddress|wscript.shell|gethostbyname|cmd.exe|documents and settings|system32|serv-u|提权|jspspy|后门" |sort -n|uniq -c |sort -rn 2>&1 |tee -a ${file_log}
    find / -type f -name *.jsp | xargs egrep -l "InputStreamReader\(this.is\)|W_SESSION_ATTRIBUTE|strFileManag|getHostAddress|wscript.shell|gethostbyname|cmd.exe|documents and settings|system32|serv-u|提权|jspspy|后门" |sort -n|uniq -c |sort -rn| awk '{print $2}' | xargs -I{} cp {} /tmp/  2>&1
    echo "可疑程序已拷贝到/tmp/目录" |tee -a ${file_log}
else
    echo "未检测到 JSP 可疑程序" |tee -a ${file_log}
fi

echo -e "\n检查 HTML 可疑程序：" |tee -a ${file_log}
if find / -type f -name *.html | xargs egrep -l "WriteData|svchost.exe|DropPath|wsh.Run|WindowBomb|a1.createInstance|CurrentVersion|myEncString|DropFileName|a = prototype;|204.351.440.495.232.315.444.550.64.330" 1>/dev/null 2>&1;then
    echo "发现 HTML 可疑程序" |tee -a ${file_log}
    find / -type f -name *.html | xargs egrep -l "WriteData|svchost.exe|DropPath|wsh.Run|WindowBomb|a1.createInstance|CurrentVersion|myEncString|DropFileName|a = prototype;|204.351.440.495.232.315.444.550.64.330" |sort -n|uniq -c |sort -rn |tee -a ${file_log}
    find / -type f -name *.html | xargs egrep -l "WriteData|svchost.exe|DropPath|wsh.Run|WindowBomb|a1.createInstance|CurrentVersion|myEncString|DropFileName|a = prototype;|204.351.440.495.232.315.444.550.64.330" |sort -n|uniq -c |sort -rn| awk '{print $2}' | xargs -I{} cp {} /tmp/
    echo "可疑程序已拷贝到/tmp/目录" |tee -a ${file_log}
else
    echo "未检测到 HTML 可疑程序" |tee -a ${file_log}
fi

echo -e "\n检查 Perl 可疑程序：" |tee -a ${file_log}
if find / -type f -name *.pl | xargs egrep -l "SHELLPASSWORD|shcmd|backdoor|setsockopt|IO::Socket::INET;" 1>/dev/null 2>&1;then
    echo "发现 Perl 可疑程序" |tee -a ${file_log}
    find / -type f -name *.pl | xargs egrep -l "SHELLPASSWORD|shcmd|backdoor|setsockopt|IO::Socket::INET;"|sort -n|uniq -c |sort -rn |tee -a ${file_log}
    find / -type f -name *.pl | xargs egrep -l "SHELLPASSWORD|shcmd|backdoor|setsockopt|IO::Socket::INET;"|sort -n|uniq -c |sort -rn| awk '{print $2}' | xargs -I{} cp {} /tmp/
    echo "可疑样本已拷贝到/tmp/目录" |tee -a ${file_log}
else
    echo "未检测到 Perl 可疑程序" |tee -a ${file_log}
fi

echo -e "\n检查 Python 可疑程序：" |tee -a ${file_log}
if find / -type f -name *.py | xargs egrep -l "execCmd|cat /etc/issue|getAppProc|exploitdb" 1>/dev/null 2>&1;then
    echo "发现 Python 可疑程序" |tee -a ${file_log}
    find / -type f -name *.py | xargs egrep -l "execCmd|cat /etc/issue|getAppProc|exploitdb" |sort -n|uniq -c |sort -rn |tee -a ${file_log}
    find / -type f -name *.py | xargs egrep -l "execCmd|cat /etc/issue|getAppProc|exploitdb" |sort -n|uniq -c |sort -rn| awk '{print $2}' | xargs -I{} cp {} /tmp/
    echo "可疑程序已拷贝到/tmp/目录" |tee -a ${file_log}
else
    echo "未检测到 Python 可疑程序" |tee -a ${file_log}
fi

echo -e "\n检查 系统 可疑程序：" |tee -a ${file_log}
if find / -type f -perm -111  |xargs egrep "UpdateProcessER12CUpdateGatesE6C|CmdMsg\.cpp|MiniHttpHelper.cpp|y4'r3 1uCky k1d\!|execve@@GLIBC_2.0|initfini.c|ptmalloc_unlock_all2|_IO_wide_data_2|system@@GLIBC_2.0|socket@@GLIBC_2.0|gettimeofday@@GLIBC_2.0|execl@@GLIBC_2.2.5|WwW.SoQoR.NeT|2.6.17-2.6.24.1.c|Local Root Exploit|close@@GLIBC_2.0|syscall\(\__NR\_vmsplice,|Linux vmsplice Local Root Exploit|It looks like the exploit failed|getting root shell" 1>/dev/null 2>&1;then
    echo "发现系统 可疑 程序" |tee -a ${file_log}
    find / -type f -perm -111  |xargs egrep "UpdateProcessER12CUpdateGatesE6C|CmdMsg\.cpp|MiniHttpHelper.cpp|y4'r3 1uCky k1d\!|execve@@GLIBC_2.0|initfini.c|ptmalloc_unlock_all2|_IO_wide_data_2|system@@GLIBC_2.0|socket@@GLIBC_2.0|gettimeofday@@GLIBC_2.0|execl@@GLIBC_2.2.5|WwW.SoQoR.NeT|2.6.17-2.6.24.1.c|Local Root Exploit|close@@GLIBC_2.0|syscall\(\__NR\_vmsplice,|Linux vmsplice Local Root Exploit|It looks like the exploit failed|getting root shell" 2>/dev/null |tee -a ${file_log}
    #echo "可疑程序已拷贝到/tmp/目录"
else
    echo "未检测到 系统 可疑程序" |tee -a ${file_log}
fi

echo -e "\n检查系统中 core 文件是否开启：" |tee -a ${file_log}
echo "core 是 unix 系统的内核。当你的程序出现内存越界的时候,操作系统会中止你的进程,并将当前内存状态倒出到 core 文件中,以便进一步分析，如果返回结果为0，则是关闭了此功能，系统不会生成 core 文件" |tee -a ${file_log}
ulimit -c |tee -a ${file_log}







# ls /etc/rc.d
# ls /etc/rc3.d
# find / -type f -perm 4000    #查看是否为管理员增加或者修改
# 目录权限

# rpm -Vf /bin/ls
# rpm -Vf /usr/sbin/sshd
# rpm -Vf /sbin/ifconfig
# rpm -Vf /usr/sbin/lsof

# md5sum –b 文件名
# md5sum –t 文件名


# boot grub

# kvm  vnc










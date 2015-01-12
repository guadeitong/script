#!/bin/bash

#引入系统环境变量
if [ -f /etc/init.d/functions ];then
. /etc/init.d/functions;
fi

#硬件架构
platform=`uname -m` 
if [ $platform != "x86_64" ];then 
echo  "Only for x86_64 OS!" 
exit 1 
fi 
echo  "platform is ok" 

#操作系统或内核名称
operation=`uname -s`
if [ $operation != "Linux" ];then
echo "Only for Linux"
exit 1
fi
echo "Operation system is ok"

#操作系统发行版本
version=`cat /etc/*-release*|grep -o -E  "CentOS|Red Hat"|uniq`
if [ -z $version ];then
echo "Only for 'CentOS and Red Hat '"
exit 1
fi
echo "Release is ok"
 
#初始化DNS地址(北京地区DNS)
cat > /etc/resolv.conf <<EOF
nameserver 202.106.0.20
nameserver 202.106.196.115
nameserver 8.8.8.8
EOF
echo "DNS完成"
echo ;

#修改系统启动模式为3,并屏蔽selinux,取消额外系统进程与服务
PID_1=`ll /proc/1/exe | awk -F' ' '{print $11}'`
if  [ $PID_1 == "/sbin/init" ];then
yum install sed -y 
sed -i 's/id:5:initdefault:/id:3:initdefault:/g' /etc/inittab 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
chkconfig --list |awk '{ print $1 }'|grep -v "^crond" |grep -v "^network" |grep -v "^sshd"|grep -v "^rsyslog" > chkconfig.txt;for i in `cat ./chkconfig.txt`; do { echo  "##### $i ####"; chkconfig --level 3 $i off;  } done  
echo "启动模式,selinux,chkconfig完成"
echo 
else [ $PID_1 == "/usr/lib/systemd/systemd" ]
rm -f  /etc/systemd/system/default.target
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi
echo "系统启动模式,取消额外系统进程与服务完成"

#初始化字体显示
cat > /etc/sysconfig/i18n <<EOF
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN.GB18030:zh_CN.GB2312:zh_CN.UTF-8:zh_CN:zh:en_US.UTF-8:en_US:en"
SUPPORTED="zh_CN.GB18030:zh_CN.GB2312:zh_CN.UTF-8:zh_CN:zh:en_US.UTF-8:en_US:en"
SYSFONT="lat0-sun16" 
SYSFONTTACH="8859-15"
EOF
echo "字体初始化完成"
echo ;

#初始化时钟与区域
cp -aprf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
cat > /etc/sysconfig/clock <<EOF
ZONE="Asia/Shanghai"
UTC=true
ARC=false
EOF
yum -y install ntp;
/usr/sbin/ntpdate ntp.api.bz
date
hwclock --systohc
echo  "01 * * * * /usr/sbin/ntpdate ntp.api.bz" >> /var/spool/cron/root 
echo "时钟与区域设置完成"
echo ;

#设置系统打开文件数限制
echo  "ulimit -SHn 102400" >> /etc/rc.local 
cat >> /etc/security/limits.conf << EOF 
*           soft   nofile       65535 
*           hard   nofile       65535 
EOF
echo "系统打开文件数限制完成"
echo ;

#关闭IPV6；
echo  "NETWORKING_IPV6=off" >> /etc/sysconfig/network 
echo "IPV6关闭"
echo ;

#添加admin账户
useradd admin
echo  "请输入新添加的admin账户密码(Input the admin conout password！)";
passwd admin;

#删除系统安装日志
cd /home/admin/;
mv /etc/issue /home/admin/
mv /etc/issue.net /home/admin/
touch /etc/issue 
touch /etc/issue.net

#屏蔽除admin账户外的其他用户su到root账户
usermod -G10 admin;
#sed -e '6s/^#//g'  /etc/pam.d/su;
sed -i '6s/^#//g'  /etc/pam.d/su;

#禁止root远程登录;
sed -i 's/\#PermitRootLogin\ yes/PermitRootLogin\ no/g' /etc/ssh/sshd_config 
sed -i 's/^Protocol.*/Protocol\ 2/g'  /etc/ssh/sshd_config
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config 
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config 
echo  "AllowUsers admin" >> /etc/ssh/sshd_config
service sshd restart;
echo "禁止root远程登录完成,禁止admin外的其他用户切换root完成"
echo ;

#调整系统参数
cat >> /etc/sysctl.conf << EOF 
kernel.sysrq = 0 
kernel.core_uses_pid = 1 
net.ipv4.conf.default.accept_redirects = 0 
net.ipv4.conf.default.log_martians = 1 
net.ipv4.conf.default.rp_filter = 1 
net.ipv4.conf.default.accept_source_route = 0   
net.ipv4.icmp_echo _ignore_broadcasts = 1 
net.ipv4.icmp_ignore_bogus_error_responses = 1 
net.ipv4.icmp_echo _ignore_all = 0
net.ipv4.tcp_reordering = 5 
net.ipv4.tcp_synack_retries = 2 
net.ipv4.tcp_syn_retries = 3 
net.ipv4.tcp_max_syn_backlog = 2048 
net.ipv4.tcp_max_tw_buckets = 360000 
net.ipv4.tcp_rmem = 4096 87380 8388608 
net.ipv4.tcp_wmem = 4096 65535 8388608 
net.ipv4.tcp_mem = 8388608 8388608 8388608 
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 25 
net.ipv4.tcp_keepalive_time = 1200 
net.ipv4.tcp_window_scaling = 1 
net.ipv4.tcp_sack = 1 
net.ipv4.tcp_fack = 1 
net.ipv4.tcp_timestamps = 1 
net.ipv4.tcp_syncookies = 1 
net.core.optmem_max = 40960
net.core.netdev_max_backlog = 8096
net.core.rmem_default = 65535 
net.core.rmem_max = 8388608 
net.core.wmem_default = 65535 
net.core.wmem_max = 8388608 
vm.overcommit_memory = 1
EOF
/sbin/sysctl -p
echo "系统内核参数已调整"
echo ;



echo  <<EOF
####
3.1.服务器硬盘分区是否合理；
3.2.服务器标准密码更新；
3.3.操作系统版本是否符合要求；
3.4.当前新服务器是否屏蔽不必要服务；
3.5.新服务器上是否进行旧文件清理，包括游戏代码等数据信息；
3.6.计划任务是否设置合理；
3.7.开机启动文件设置是否合理；
3.8.服务器IP、网关信息是否正确，检查路由表，通知机房取消不必要的机柜访问限制；
3.9.更新机器名称hosts、sysconfig/network、DNS解析设置resolv.conf文件；
3.10.检查系统文件同步是否正常，sudo执行效率是否正常；
3.11.检查并更新监控系统Nagios；
####
EOF

echo ;
echo  "请重启计算机....";:

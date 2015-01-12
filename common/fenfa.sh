#!/bin/sh
#→实现把脚本当前目录下的文件拷贝到所有服务器的任意目录
. /etc/init.d/functions
file="$1"   #→传参文件
remote_dir="$2"   #→远程服务器目录
if [ $# -ne 2 ];then      #→如果传的参数不等于2个，那么就打印如下报错信息。
#→ $#：获取当前shell命令行中的参数的总个数
#→ -ne：不等于
echo "usage:$0 argv1 argv2"
#→$0：首个参数（fenfa_host.sh）
echo "must have two argvs."
exit
fi
for ip in $(cat iplist.txt)
#→$()：在脚本里引用全局变量
do
scp -P4399 -r -p $file binzai@$ip:~ >/dev/null 2>&1 &&\
#→将hosts文件传到binzai家目录下，如果没有传递过去，将丢弃到/dev/null
ssh -p4399 -t binzai@$ip sudo rsync -avz -P $file $remote_dir >/dev/null 2>&1
#→通过ssh通道执行sudo命令将hosts文件拷贝到/etc目录下
if [ $? -eq 0 ];then   #→如果上次执行结果返回值等于0，则执行OK。如果不等于0，则执行NO
#→$?：上次执行结果的返回值
#→-eq：等于
action "$ip is successful." /bin/true
else
action "$ip is failure." /bin/false
fi
done
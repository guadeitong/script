#!/bin/bash
#Rsync the ziyuan to local and remote server;
#By Chenxin 20120712

[ -f /etc/init.d/functions ] && . /etc/init.d/functions || . /lib/lsb/init-functions
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
version=honor_rs_mixed_seacs
upload_dir=/home/honor/online/source/honor_rs_mixed_seacs/
download_dir=/home/www/honor_rs_mixed_seacs/
bak_dir=/data/honor_rs_bak/honor_rs_mixed_seacs/ 

/bin/echo "##########  ${version}'s resources from upload_dir to download_dir  in `date '+%Y%m%d%H%M'` ############"  
/bin/echo -ne "\n\n"
/bin/echo "<br>"
/usr/local/bin/rsync  -vzrltopg  --delete --progress --exclude "logs" ${upload_dir} ${download_dir}  
/bin/echo -ne "\n\n"
/bin/echo "<br>"
/bin/echo "##########   resources from upload_dir to download_dir  over  in `date '+%Y%m%d%H%M'` ############"   
/bin/echo -ne "\n"
/bin/echo "<br>"
/bin/echo "##########  ${version}'s local backup  in `date '+%Y%m%d%H%M'`  ############"  
/bin/echo -ne "\n\n"
/bin/echo "<br>"
/usr/local/bin/rsync  -vzrltopg  --delete --progress --exclude "logs" ${upload_dir} ${bak_dir}
/bin/echo -ne "\n\n"
/bin/echo "<br>"
/bin/echo "##########  local backup over in `date '+%Y%m%d%H%M'`  ############"  
/bin/echo -ne "\n"
/bin/echo "<br>"

#!/bin/bash

if [ -f /etc/init.d/functions ];then
. /etc/init.d/functions
fi

USER="honor"
Edition="yy_cncs"
Zone="1001"

init_first () {
  if id $USER >/dev/null 2>&1
  then
    echo "$USER already exists"
  else
    echo "add user $USER"
    /usr/sbin/groupadd $USER && /usr/sbin/useradd -m -g $USER $USER
    mkdir /home/online && pushd /home/online &&  mkdir apps  gameserver  logs  redis  sync source && popd
    echo "*/5 * * * * /bin/chmod 775 /home/$USER -R;/bin/chown $USER.$USER /home/USER -R" >> /var/spool/cron/root
  fi
} 

init_second () {
  echo -e "1.GM"
  echo -e "2.Login"
  echo -e "3.Account"
  echo -e "4.Payment"
  echo -e "5.Source"
  echo -e "6.List"
  echo -e "7.JMS"
  echo -e "8.Fight"
  echo -e "9.Game"
  read "Please select a feature" i
  case $i in
    1)
      mkdir /home/$USER/online/apps/tomcat_${USER}_gm_${Edition}
      ;;
    2)
      mkdir /home/$USER/online/apps/tomcat_${USER}_login_${Edition}
      ;;
    3)
      add_database(account)
      ;;
    4)
      mkdir /home/$USER/online/apps/tomcat_${USER}_payment_${Edition}
      add_database(payment)
      ;;
    5)
      mkdir /home/$USER/online/source/${USER}_rs/${Edition}
      ;;
    6)
      mkdir /home/$USER/online/gameserver/list_server/${USER}_list_${Edition}_${Zone}
      ;;
    7)
      mkdir /home/$USER/online/apps/activemq_${USER}_jms_${Edition}_${Zone}
      ;;
    8)
      mkdir /home/$USER/online/gameserver/fight_servers/${USER}_fight_${Edition}_${Zone}
      ;;
    9)
      mkdir /home/$USER/online/gameserver/${USER}_gs_${Edition}_${Zone}
      ;;
    *)
      help()
  esac
}

add_DB() {
  passwd='iconv!@#webssz'
  /usr/local/mysql/bin/mysqll -uadmin -p${passwd}
  
  
}

add_DBuser() {
  DBusers=`/usr/local/mysql/bin/mysql -uadmin -p$DBpw -e "select user from mysql.user where user = '$DBuser'"`
  if [[  DBusers == ' ' ]];then
    /usr/local/mysql/bin/mysql -uadmin -p$DBpw -e <
}

add_DBtable() {
  
}


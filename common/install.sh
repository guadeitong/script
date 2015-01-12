#!/bin/bash

function build_project () {

    #judge project's user whether it exists,if not  add it
    grep  "${Project}" /etc/passwd || useradd ${Project}
    #build works directory
    mkdir /home/${Project}/online/{apps,gameserver,logs,redis,sync,source} -p

}

function Set_Variable () {

    Project=honor
    Version=mixed_seacs_1001
    Version_
    dbuser=admin
    dbpwd=iconv!@#webssz
    dbadmin=honorsql
    dbadminpwd=cN!kQ7B8@wV3kC
    port_shtdown=8050
    port_http=8055
    port_ajp=8059
    locate_shutdown=`grep -n -o "SHUTDOWN" ./tomcat/conf/server.xml | awk -F: '{print $1}'`
    locate_http=`grep -o -n "Connector port=\"8080\" protocol=\"HTTP\/1.1\"" ./tomcat/conf/server.xml | awk -F: '{print $1}'`
    locate_ajp=`grep -n -o "protocol=\"AJP/1.3\"" ./tomcat/conf/server.xml | awk -F: '{print $1}'`
    private_ip=`/sbin/ifconfig $1 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'|grep -E "10\.|192.168"`
    public_ip=`/sbin/ifconfig $1 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'|grep -v -E "10\.|192.168|127.0.0.1"`
    Java_Opts='JAVA_OPTS="$JAVA_OPTS  -server -Xms2048m -Xmx2048m -XX:PermSize=128m -XX:MaxPermSize=256m "'

}

function Ready () {

    tar -zxvf  apache-tomcat-7.0.42.tar.gz
    mv apache-tomcat-7.0.42 tomcat
    unzip apache-activemq-5.9.0.zip

}

function Clean () {

    rm -rf apache-tomcat-7.0.42.tar.gz apache-activemq-5.9.0.zip tomcat apache-activemq-5.9.0 pri.sql

}

function GM () {

    cp -arpvf tomcat /home/${Project}/online/apps/${Project}_gm_${Version}
    sed -i "${locate_shutdown} s/8005/${port_shtdown}/g" /home/${Project}/online/apps/${Project}_gm_${Version}/conf/server.xml
    sed -i "${locate_http} s/8080/${port_http}/g" /home/${Project}/online/apps/${Project}_gm_${Version}/conf/server.xml
    sed -i "${locate_ajp} s/8009/${port_ajp}/g" /home/${Project}/online/apps/${Project}_gm_${Version}/conf/server.xml
    sed -i "239 i $Java_Opts" /home/${Project}/online/apps/${Project}_gm_${Version}/bin/catalina.sh 
    rm -rf  /home/${Project}/online/apps/${Project}_gm_${Version}/webapps/*
    Add_Database ${Project}_gm_${Version}
    Add_Database ${Project}_gmlogin_${Version}

}

function Payment () {

    cp -arpvf ./tomcat /home/${Project}/online/apps/${Project}_payment_${Version}
    sed -i "${locate_shutdown} s/8005/${port_shtdown}/g" /home/${Project}/online/apps/${Project}_payment_${Version}/conf/server.xml
    sed -i "${locate_http} s/8080/${port_http}/g" /home/${Project}/online/apps/${Project}_payment_${Version}/conf/server.xml
    sed -i "${locate_ajp} s/8009/${port_ajp}/g" /home/${Project}/online/apps/${Project}_payment_${Version}/conf/server.xml
    sed -i "239 i $Java_Opts" /home/${Project}/online/apps/${Project}_payment_${Version}/bin/catalina.sh 
    rm -rf  /home/${Project}/online/apps/${Project}_payment_${Version}/webapps/*
    Add_Database ${Project}_payment_${Version}

}

function Login () {

    cp -arpvf ./tomcat /home/${Project}/online/apps/${Project}_login_${Version}
    sed -i "${locate_shutdown} s/8005/${port_shtdown}/g" /home/${Project}/online/apps/${Project}_login_${Version}/conf/server.xml
    sed -i "${locate_http} s/8080/${port_http}/g" /home/${Project}/online/apps/${Project}_login_${Version}/conf/server.xml
    sed -i "${locate_ajp} s/8009/${port_ajp}/g" /home/${Project}/online/apps/${Project}_login_${Version}/conf/server.xml
    sed -i "239 i $Java_Opts" /home/${Project}/online/apps/${Project}_login_${Version}/bin/catalina.sh 
    rm -rf  /home/${Project}/online/apps/${Project}_login_${Version}/webapps/*

}

function Account () {

    Add_Database ${Project}_account_${Version}

}
function JMS () {

    cp -arpvf ./apache-activemq-5.9.0  /home/${Project}/online/apps/${Project}_jms_${Version}
    sed -i '155 s/1/4/g' /home/${Project}/online/apps/${Project}_jms_${Version}/bin/activemq

}

function List  () {

    mkdir  /home/${Project}/online/gameserver/${Project}_list_${Version}

}

function Source () {

    grep ${Project} /etc/passwd || useradd  ${Project}
    mkdir /home/${Project}/${Project}_rs_${Version} -p
    mkdir /home/${Project}/{cgi-bin,webapps/rs_${Project}_${Version}} -p

}

function Fight () {

    mkdir  /home/${Project}/online/gameserver/${Project}_fight_${Version}

}

function GS () {

    mkdir  /home/${Project}/online/gameserver/${Project}_gs_${Version}
    mkdir /home/${Project}/online/redis/redis_${Project}_${Version}/{conf,data,logs,run} -p
    cat >> /home/${Project}/online/redis/redis_${Project}_${Version}.sh << EOF
/usr/local/redis-2.4.10/src/redis-server /home/${Project}/online/redis/redis_${Project}_${Version}/conf/redis.conf
EOF
    chmod +x /home/${Project}/online/redis/redis_${Project}_${Version}.sh
    cp ./redis.conf /home/${Project}/online/redis/redis_${Project}_${Version}/conf/
    sed -i "s/10.0.0.1/${private_ip}/g" /home/${Project}/online/redis/redis_${Project}_${Version}/conf/redis.conf
    sed -i "s/\/home/\/home\/${Project}\/online\/redis\/redis_${Project}_${Version}\//g" /home/${Project}/online/redis/redis_${Project}_${Version}/conf/redis.conf

}

function Add_Database () {
 
    /usr/local/mysql/bin/mysql -u${dbuser} -p${dbpwd} --default-character-set=utf8 -e "create database if not exists $1;"
    cat > ./pri.sql <<EOF
GRANT ALL PRIVILEGES ON $1.* TO ${dbadmin}@localhost IDENTIFIED BY '${dbadminpwd}';
GRANT ALL PRIVILEGES ON $1.* TO ${dbadmin}@'10.%' IDENTIFIED BY '${dbadminpwd}';  
GRANT ALL PRIVILEGES ON $1.* TO ${dbadmin}@'192.168.%' IDENTIFIED BY '${dbadminpwd}';  
GRANT ALL PRIVILEGES ON $1.* TO ${dbadmin}@'125.71.203.241' IDENTIFIED BY '${dbadminpwd}';  
GRANT ALL PRIVILEGES ON $1.* TO ${dbadmin}@'114.112.69.125' IDENTIFIED BY '${dbadminpwd}';
GRANT ALL PRIVILEGES ON $1.* TO ${dbadmin}@'119.4.240.191' IDENTIFIED BY '${dbadminpwd}';  
GRANT ALL PRIVILEGES ON $1.* TO ${dbadmin}@'125.70.0.195' IDENTIFIED BY '${dbadminpwd}';  
flush privileges;
EOF
    /usr/local/mysql/bin/mysql -u${dbuser} -p${dbpwd} --default-character-set=utf8 $1 < ./pri.sql

}

function main () {

    Set_Variable
    Ready
    echo -e "1.GM"
    echo -e "2.Login"
    echo -e "3.Account"
    echo -e "4.Payment"
    echo -e "5.Source"
    echo -e "6.List"
    echo -e "7.JMS"
    echo -e "8.Fight"
    echo -e "9.Game"
    echo -e "10.BuildProject"
    read -p "Please select a feature:" i

    case $i in
        1)
            GM
            ;;
        2)
            Login
            ;;
        3)
            Account
            ;;
        4)
            Payment

            ;;
        5)
            Source
            ;;
        6)
            List
            ;;
        7)
            JMS 
            ;;
        8)
            List
            ;;
        9)
            GS
            ;;
        10)
            build_project
            ;;
        *)
            help
            ;;
    esac  
    Clean

}

main 
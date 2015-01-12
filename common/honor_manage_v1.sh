#!/bin/bash

. /etc/init.d/functions && export TERM=linux  

Project=honor
if [ `whoami` != "$Project" ];then
    echo -e "please 'su - $Project'"
    exit 1
fi
workdir="/home/$Project/online"

ready_for_game () {
    if [ -n "${gamezone_name}" ];then
            echo "$gamezone_name">/home/${Project}/game_server_list.tmp
            find_result=$?
            if [[ "$find_result" != "0" ]];then
                    echo -e "\033[43;31;5m --- /home/${Project}/game_server_list.tmp File Privilege Error --- \033[0m"
                    exit 1
            fi
    else
            find $workdir -maxdepth 2 -type d -name ${Project}_*_* |awk -F "/" '{print $6}'> /home/${Project}/game_server_list.tmp
            find_result=$?
            if [[ "$find_result" != "0" ]];then
                    echo -e "\033[43;31;5m --- /home/${Project}/game_server_list.tmp File Privilege Error --- \033[0m"
                    exit 1
            fi
    fi
}

check_md5sum () {
    for i in `cat /home/${Project}/game_server_list.tmp` 
    do {
    if [ -e ${workdir}/gameserver/${i}/${Project}_${version}.md5 ];then
	    md5sum -c   ${workdir}/gameserver/${i}/${Project}_${version}.md5 > temp.md5sum 2>&1
	    dis=`cat temp.md5sum|grep -E 'WARNING|警告'|awk -F: '{print $2}'`
	    if [ -n "$dis" ];then
	           	    echo -e "\033[43;31;5m --- file dont't match --- \033[0m"
		    exit 1
	    else
		    echo -e "\033[40;32;5m ---continuing--- \033[0m"
	    fi		
    else
 	    echo -e "\033[43;31;5m --- md5 file not exists --- \033[0m"
            exit 1
    fi
       } done
}

start_game_and_log_server () {
        #start the game server;
        for i in `cat /home/${Project}/game_server_list.tmp`
        do {
        expect -c "
        set timeout 60
        send \"script /dev/null\r\"
        eval spawn screen -S $i
        sleep 2
        send \"cd ${workdir}/gameserver/$i/\r\"
        send \"sudo ${workdir}/gameserver/$i/GameServer.sh\r\"
        expect \"cmd>\"
        sleep 2
        send  \"\001\"
        send \"d\"
        expect eof"
        } done

        #start the game server log to file;
        for i in `cat /home/${Project}/game_server_list.tmp`
        do {
        expect -c "
        set timeout 60
        send \"script /dev/null\r\"
        eval spawn screen -S ws_$i
        sleep 2
        send \"cd ${workdir}/gameserver/$i/\r\"
        send \"sudo ${workdir}/gameserver/$i/WriteLogServer.sh\r\"
        expect \"cmd>\"
        sleep 2
        send  \"\001\" 
        send \"d\"
        expect eof"
        } done
}


stop_game_and_log_server () {
        #stop the game server;
        for i in `cat /home/${Project}/game_server_list.tmp`
        do {
        expect -c "
        set timeout 60
        send \"script /dev/null\r\"
        eval spawn screen -r $i
        send \"stop\r\"
        expect \"application will exit\"
        sleep 10
        send  \"\004\" 
        expect eof"
        } done

        #stop the game log service;
        for i in `cat /home/${Project}/game_server_list.tmp`
        do {
        expect -c "
        set timeout 180
        send \"script /dev/null\r\"
        eval spawn screen -r ws_$i
        send \"stop\r\"
        expect \"application will exit\"
        sleep 10
        send  \"\004\" 
        expect eof"
        } done
}

#The preparation stage of redis
ready_for_redis () {
    redis_version=`find /usr/local/ -maxdepth 1 -type d -name "redis-*"`
    if [[ -n $rediszone_name ]];then
        echo "$rediszone_name" > /home/${Project}/redis_server_list.tmp
        find_result=$?
        if [[ $find_result != "0" ]];then
            echo -e "\033[43;31;5m --- /home/${Project}/redis_server_list.tmp File Privilege Error --- \033[0m"
            exit 1
        fi
    else
        find ${workdir} -maxdepth 2 -type d -name redis_${Project}_* |awk -F "/" '{print $6}' > /home/${Project}/redis_server_list.tmp
         find_result=$?
        if [[ $find_result != "0" ]];then
            echo -e "\033[43;31;5m --- /home/${Project}/redis_server_list.tmp File Privilege Error --- \033[0m"
            exit 1
        fi
    fi
}

#start the redis server;
start_redis_server () {
        for i in `cat /home/${Project}/redis_server_list.tmp`
        do {
        echo "--------------------------------------------"
        sudo ${workdir}/redis/${i}.sh
        start_result=$?
        if [[ "$start_result" == "0" ]];then
        echo -e "\033[40;32;1m ### $i Start succeed! ..Wait for 20 secs.. ### \033[0m" && sleep 20
        else
        echo -e "\033[43;31;5m --- $i Redis Start Error --- \033[0m" 
        fi
        } done
} 

#stop the redis server;
stop_redis_server () {
        for i in `cat /home/${Project}/redis_server_list.tmp`
        do {
        echo "--------------------------------------------"
        curr_date=`date +%y%m%d%H%M`
        redis_pass=`cat ${workdir}/redis/$i/conf/redis.conf |grep requirepass|awk '{print $2}'`
        redis_port=`cat ${workdir}/redis/$i/conf/redis.conf |grep port|awk '{print $2}'`
        redis_address=`cat ${workdir}/redis/$i/conf/redis.conf |grep bind|awk '{print $2}'`
        #get the bound ip address,if null,give the blank space for the default
        redis_address_length=`expr length $redis_address\ `
        if [ $redis_address_length -gt 6 ];then
                redis_address_h="-h $redis_address"
        else
                redis_address_h="";
        fi
        echo -e "\033[40;32;1m ### $i Wait for some seconds to save the redis! ### \033[0m" 
        while true;
        do
                redis_connects=`netstat -na | grep ESTABLISHED|grep ":$redis_port"|wc -l`
                if (( $redis_connects > 4 ));then
                        echo -e "\033[43;31;5m -- $i at port $redis_port has "$redis_connects" connects ,could not stop -- \033[0m"
                        echo -n "do you want to stop it force y/n?"
                        read y
                        if [ $y = "y" ];then
                                echo "force close it now"
                                break
                        fi
                        echo "wait 5 secs to check connects again"
                        sleep 5
                else
                        break
                fi
        done
        ${redis_version}/src/redis-cli -p $redis_port $redis_address_h -a $redis_pass save;
        save_result=$?
        if [[ "$save_result" == "0" ]];then
                echo -e "\033[40;32;1m ### $i Save succeed! ### \033[0m"
                #Try to shutdown the redis services
                echo -e "\033[40;32;1m ### $i Wait,SHUTDOWN redis! ### \033[0m"
                ${redis_version}/src/redis-cli -p $redis_port $redis_address_h -a $redis_pass shutdown;
                shutdown_result=$?
                if [[ "$shutdown_result" == "0" ]];then
                        echo -e "\033[40;32;1m ### $i Shutdown succeed! ### \033[0m"
                        #backup the phyic file
                        echo -e "\033[40;32;1m ### $i Wait,backup dump.rdb to /home/${Project}/redis_data_bak Directory ### \033[0m"
                        mkdir -p /home/${Project}/redis_data_bak   #bak the redis file if stop server to  directory
                        cp -aprf ${workdir}/redis/$i/data/dump.rdb /home/${Project}/redis_data_bak/dump_"$i"_"$curr_date".rdb
                        cp_result=$?
                        if [[ "$cp_result" == "0" ]];then
                                echo -e "\033[40;32;1m ### $i cp dump.rdb to /home/${Project}/redis_data_bak succeed! ### \033[0m"
                                find -L /home/${Project}/redis_data_bak/ -mtime +45 -name "*.rdb" -exec rm -rf {} \;
                        else
                                echo -e "\033[43;31;5m --- $i cp dump.rdb to /home/${Project}/redis_data_bak Error --- \033[0m"
                        fi
                else
                        echo -e "\033[43;31;5m --- $i Redis SHUTDOWN Error --- \033[0m" 
                fi
        else
                echo -e "\033[43;31;5m --- $i Redis save Error,shutdown Error --- \033[0m" 
        fi
        } done
}

#save redis
save_redis_server () {
        for i in `cat /home/${Project}/redis_server_list.tmp`
        do {
        echo "--------------------------------------------"
        redis_pass=`cat ${workdir}/redis/$i/conf/redis.conf |grep requirepass|awk '{print $2}'`
        redis_port=`cat ${workdir}/redis/$i/conf/redis.conf |grep port|awk '{print $2}'`
        redis_address=`cat ${workdir}/redis/$i/conf/redis.conf |grep bind|awk '{print $2}'`
        #get the bound ip address,if null,give the blank space for the default
        redis_address_length=`expr length $redis_address\ `
        if [ $redis_address_length -gt 6 ];then
                redis_address_h="-h $redis_address"
        else
                redis_address_h="";
        fi
        echo -e "\033[40;32;1m ### $i Wait for some seconds to save the redis! ### \033[0m" 
        ${redis_version}/src/redis-cli -p $redis_port $redis_address_h -a $redis_pass save;
        save_result=$?
        if [[ "$save_result" == "0" ]];then
                echo -e "\033[40;32;1m ### $i Save succeed! ### \033[0m"
        else
                echo -e "\033[43;31;5m --- $i Redis save Error --- \033[0m" 
        fi
        } done
}


PROG=`basename $0`

usage() {
    cat <<EOF
Usage: ${PROG} [OPTION]...
Switch is that Game,GameLog and Redis.
Example: ${PROG} game start ${Project}_gs_mixed_seacs_1001

Options:
    game       Switch is that Game and GameLog,
                    default from all game java process.
    redis     Switch is that Redis
    help      display this help and exit
EOF
    exit $1
}


if [[ $1 = "game" ]] 
then
    gamezone_name=$3
    ready_for_game
    case $2 in
    start)
    start_game_and_log_server
    ;;
    stop)
    stop_game_and_log_server
    ;;
    restart)
    stop_game_and_log_server
    start_game_and_log_server
    ;; 
    md5sum)
    check_md5sum;;
    *)
    usage 1;;
    esac
elif [[ $1 = "redis" ]]
then
    rediszone_name=$3
    ready_for_redis
    case $2 in
    start)
    start_redis_server;;
    stop)
    stop_redis_server;;
    restart)
    stop_redis_server;
    start_redis_server;;
    save)
    save_redis_server;;
    *)
    usage 1;;
    esac
else
    usage 1
fi

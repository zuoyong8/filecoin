#!/bin/bash

min=2
max=30
api_port=3453
swarm_port=6000
function check_filecoin()
{
    if [ -n `which go-filecoin` ] ;then
        echo "exists"
    else
        source /etc/os-release
        case $ID in
            debian|ubuntu|devuan)
                sudo apt-get install
                ;;
            centos|fedora|rhel)
                sudo yum install
                ;;
        esac
    fi
}

function create_master_node()
{
	rm -rf ~/.go-filecoin
    go-filecoin init --devnet-user --genesisfile=https://genesis.user.kittyhawk.wtf/genesis.car
    pids=`ps -aux | grep go-filecoin | grep -v grep | awk '{print $2}'`
	for p in $pids
	do 
		kill -9 $p
	done
    go-filecoin daemon
}

if [ ! -n "$1" ] ;then
	create_master_node
else
	if [ "$1" -gt 0 ] 2>/dev/null ;then  
    	if [ "$1" -le $max ] && [ "$1" -ge $min ] ;then
    		create_master_node
    		for((i=$min; i<=$1; i++));
    		do
    			FCOIN=$HOME/.filecoin$i
    			go-filecoin init --genesisfile=http://user.kittyhawk.wtf:8020/genesis.car --repodir=$FCOIN
    			tmp_api_port=$[$api_port+$i]
    			tmp_swarm_port=$[$swarm_port+$i]
    			sed -ie 's/'$api_port'/'$tmp_api_port'/g' $FCOIN/config.json
    			sed -ie 's/'$swarm_port'/'$tmp_swarm_port'/g' $FCOIN/config.json
    			go-filecoin daemon --repodir=$FCOIN
    		done
    	else
    		echo "$1 more than $max or $1 less than $min"
    	fi
    else
    	echo "input param is no number"
    fi 
fi


#!/bin/bash

#Login environment
OPTS="-u utenza -p password --insecure-skip-tls-verify"

#Cluster definition
cluster1="https://url:port"
cluster2="https://url:port"
cluster3="https://url:port"

#Variables
EnvList=/tmp/env_list.tmp
TMP=/tmp/checksor.tmp
Home="/home/$(whoami)/.bashrc"
LoginLog="/home/$(whoami)/LoginLog.txt"

#Remove unneccessary objects before executing
if [ -e $EnvList ]; then rm -f $EnvList; fi
if [ -e $TMP ]; then rm -f $TMP; fi
if [ -e $LoginLog ]; then rm -f $LoginLog; fi
sed -i '/# Cluster environment list/,+3d' $Home

define_file(){

    #Cycle for creating an environment list
    for ENV_LIST in "cluster1" "cluster2" "cluster3"
    do
	    echo "$ENV_LIST" >> $EnvList
    done

    #Make a cycle to read one file line by line, login one by one and then export all cluster's user token
    echo -e "\n# Cluster environment list" >> $Home
    cat $EnvList | while read line || [[ -n $line ]];
    do
        loginLink=${!line}
        oc login $loginLink $OPTS > $TMP 2>&1
        if [ "$(cat $TMP)" = "Login failed (401 Unauthorized)" ]
        then
            oc login $loginLink $OPTS --loglevel=9 >> $LoginLog
            echo "Unabel to login into $loginLink , check $LoginLog"
        fi
        echo "export $line='--server $loginLink --token=$(oc whoami -t)'" >> $Home
    done
}

define_file

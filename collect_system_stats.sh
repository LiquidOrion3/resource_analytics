#!/bin/bash

trap "exit" INT TERM
trap "echo 'process terminated ... stopping all resource logging' ;kill 0" EXIT

[ ! -f config.csv ] && echo "config.csv not found ... exiting" && exit 1
#<collect_on_host>,host,user,<pw_file>
readarray -t files <config.csv


readonly rate=1
readonly remote_cmd="./output_stats.sh"
readonly args="$rate"

function resourse_log(){

	local hostname=$1
	local username=$2
	local passwd_file=$3
	local runstate=$4

	while [ $runstate == true ]; do

		#wait untill able to ssh to host
		while [[ $(nc -z ${hostname} 22 ) == 1 ]]; do
			sleep 1
		done

		echo "$(date +%F:%T) start logging resources on ${hostname}"
	
		#write file header if file does not exist
		if [ ! -f ${hostname}.resource_log.csv ]; then
			echo "time,host,max_cores,max_memory,cpu_percent,memory_percent" >${hostname}.resource_log.csv
		fi

		sshpass -f ${passwd_file} ssh ${hostname} -l ${username} "bash -s" < $remote_cmd $args >> ${hostname}.resource_log.csv
		echo "$(date +%F:%T) stopped logging resources on ${hostname}"
	done
}

function main_function(){

	for line in ${files[@]}; do
		IFS=',';read -r -a linearry <<< $line
		if [[ ${linearry[0]} == 'y' ]]; then
			resourse_log ${linearry[1]} ${linearry[2]} ${linearry[3]} true &
		fi
	done
	
	while true; do
		sleep 30
	done

}

main_function $@ >> system_stats.out

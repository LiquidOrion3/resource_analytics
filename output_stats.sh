#!/bin/bash

readonly periodicity=$1

readonly active_cores=$(ps -e -o psr= |sort |uniq |wc -l)
readonly max_memory=$(head -1 /proc/meminfo|awk '{print $2}')

cpu_total=0
cpu_idle=0
function get_cpu_percent(){

	#compare cpu usage from now vs last time / total time

	local -n prev_cpu_total=$1
	local -n prev_cpu_idle=$2
	local -n result=$3

	cpu_line=($(sed -n 's/^cpu\s//p' /proc/stat))
	idle=${cpu_line[3]}

	total=0
	for val in "${cpu_line[@]:0:8}"; do
		total=$((total+val))
	done

	diff_idle=$((idle-prev_cpu_idle))
	diff_total=$((total-prev_cpu_total))
	result=$(echo "($diff_total-$diff_idle)/$diff_total*100" |bc -l)

	prev_cpu_total="$total"
	prev_cpu_idle="$idle"
}


function get_memory_percent(){

	#check how much memory is being used

	local -n result=$1
	local meminfo=$(grep -o '[0-9]\+' /proc/meminfo|awk NF=NF RS= OFS=' ' )
	IFS=' '; read -r -a mem_array <<< $meminfo

	result=$( echo "(${mem_array[0]} - ${mem_array[2]})/${mem_array[0]}*100" |bc -l)
}

while true; do
	get_cpu_percent cpu_total cpu_idle cpu_percent
	get_memory_percent mem_percent

	echo "$(date +%T.%N),$(uname -n),$active_cores,$max_memory,$cpu_percent,$mem_percent"

 	sleep $periodicity
done

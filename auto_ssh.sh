#!/bin/bash
####
# Provided B.Mammadov
# Required packages netcat,expect
# File Content must be  as following 
####
keypath=$HOME/.ssh/id_rsa.pub

function create_sshkeygen() {
if [ ! -f $keypath ]
then
	echo "You have no public and private key. You must create firstly these keys, If you type Yes , key files created automaticly or No you must create manually"
	read -p "Yes/No: " key
	if [ $key == 'yes' ] || [ $key == 'Yes' ] || [ $key == 'Y' ] || [ $key == 'y' ] 
    then
    	/usr/bin/expect<<EOF
    	log_file ssh_auto.log
        spawn ssh-keygen -b 2048 -t rsa  -q -N ""
        expect "):"           {send "\r"}
	expect eof
EOF
    else
    	exit 0
    fi
fi
}

function check_con() {
ip=$1
port=$2
/bin/nc -z -w5  $ip $port
status=$(echo $?)
	if [ $status  == '0' ]
	then
    	echo "Yes"
	else
    	echo "No,"
	fi
}

function auto_copyid() {
keypath=$1
user=$2
ip=$3
pass=$4
port=$5


value=$(check_con $ip $port )
echo $value | grep -iE 'Yes' >> /dev/null
if [ $? == '0' ]
then
    log_user 0
    log_file ssh_auto.log
    /usr/bin/expect<<EOF
    spawn ssh-copy-id -i $keypath  $user@$ip -p $port
    expect "(yes/no)?"           {send "yes\r"}
    expect "word:"           {send "$pass\r"}
    expect eof
EOF
    echo "You have succesfully connected to server $ip and port $port" >> yesconnectionip.list
else
    echo "You have problem with connection to server $ip and port $port" >> noconnectionip.list
fi

}



function main(){
	create_sshkeygen
	while read line
	do
	   os_ip=$(echo $line  | awk -F'|' '{ print $1}')
       # Delete existing  ip and ket from hosts known file
       sed -i "/$os_ip/d" ~/.ssh/known_hosts
	   os_user=$(echo $line  | awk -F'|' '{ print $2}')
	   os_pass=$(echo $line  | awk -F'|' '{ print $2}')
	   os_port=$(echo $line  | awk -F'|' '{ print $2}')
	   auto_copyid $keypath $os_user $os_ip $os_pass $os_port
        done < ip.txt
}
main


#!/bin/bash

#============================================================
## debug tools
# set -x	#Print all  trace and arguments
# trap -l	#List of signals

#============================================================
## variables definition
# CAPITALS = environment variables
# lower_case = script variables
# camelType = function (only log fce has the exception)

#============================================================
## info
# author:     		
# version:		
# description:		
# todo:			

#============================================================
## default variables
set -o nounset				#all variable must be defined
emial_notification=no		#yes/no (if yes script sends email if error (cron script))
log_interactive=yes			#yes/no (if yes logs are print to screen also)
error_stop=no           	#yes/no (if yes script stops after error)
script_name=`basename $0`
script_path=`dirname $(readlink -nf $0)`
if ! [ -d "${script_path}/tmp" ]; then mkdir ${script_path}/tmp ; fi
script_path_temp=${script_path}/tmp		#folder for temp files
if ! [ -d "${script_path}/log" ]; then mkdir ${script_path}/log ; fi
log_path=${script_path}/log				#folder for log files
log_file=${log_path}/${script_name}.log

#============================================================
## test if script is running already
if [ `ps -e | grep -c ${script_name}` -gt 2 ]; then
        echo "[`date +"%Y-%m-%d %H:%M:%S"` $BASHPID] [E] Script ${script_name} is already running. Exit!" >> ${log_file}
	if [ "$log_interactive" = "yes" ]; then echo "[E] Script ${script_name} is already running. Exit!" ; fi
        exit 0
fi

#============================================================
## default functions
log () {
	if [ "$log_interactive" = "yes" ]; then
		echo "[`date +"%Y-%m-%d %H:%M:%S"` $BASHPID] $@" >> ${log_file}
		echo "$@"
	else
		echo "[`date +"%Y-%m-%d %H:%M:%S"` $BASHPID] $@" >> ${log_file}
	fi
}

fceLogStart () {
        log "[I] ----------------------------------------"
        case "$-" in
            *i*)
                local user_start_script1="interactive"
                local user_start_script2=`who mom likes`
                ;;
            *)
                local user_start_script1="not_interactive"
                local user_start_script2=`whoami`
                ;;
        esac
	log "[I] Script started by ${user_start_script2}-${user_start_script1}"
}

fceLogStop () {
	log "[I] Script run total $SECONDS seconds"
	case $@ in
		OK)
			log "[I] Script end with SUCCESS";;
		NOK)
			log "[I] Script end with ERROR";;
	esac
}

errorExit() {
	log "[E] Signal: exit On line: $1 Command was: $3 Error code: $2"
	errorEmail
	fceLogStop NOK
	exit 0
}

errorInterupt() {
	log "[E] Signal: interrupt On line: $1 Command was: $3 Error code: $2"
	errorEmail
	fceLogStop NOK
	exit 0
}

errorEmail() {
   if [ "$emial_notification" = "yes" ]; then
        echo "[S] Script end with ERROR" >> ${log_file}
        local email_sender="`whoami`@`hostname`"
        local email_recipient="email@domain.com"
	touch ${script_path_temp}/mail_body
        local mail_trigger=${script_path_temp}/mail_trigger
        local mail_body=${script_path_temp}/mail_body
        rm -f ${mail_body}
        echo -e "You should check the logfile: ${log_file}\nThen delete the trigger file: ${mail_trigger}\nTrigger will be delete automaticly within 24 hours.\n" > ${mail_body}
        echo -e "***LAST 20 LINES FROM LOG***\n" >> ${mail_body}
        tail -n 20 ${log_file} >> ${mail_body}

        if test `find "${mail_trigger}" -mtime +1 2>/dev/null` ; then
                rm -f ${mail_trigger}
        fi
        if [ ! -e ${mail_trigger} ] ; then
                mail -s "ERROR appeared in script ${script_name}" -r "$email_sender" "$email_recipient" < ${mail_body}
                touch ${mail_trigger}
        fi
   fi
}

#============================================================
## set error handling
if [ "$error_stop" = "yes" ]; then
  trap 'errorExit $LINENO $? $BASH_COMMAND' ERR
  trap 'errorInterupt $LINENO $? $BASH_COMMAND' SIGHUP SIGINT SIGQUIT
fi

#///////////////////////////////////////////////////////////#
#============================================================
## script functions

#============================================================
## script variables

#============================================================
## script code
fceLogStart

echo "Hello World!"

#///////////////////////////////////////////////////////////#
#============================================================
## script ends
fceLogStop OK

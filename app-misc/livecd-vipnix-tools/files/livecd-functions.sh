#!/bin/bash

# Global Variables:
#    CDBOOT                  -- is booting off CD
#    LIVECD_CONSOLE          -- console that is specified on commandline 
#                            -- (ttyS0, etc) Only defined if passed to kernel
#    LIVECD_CONSOLE_BAUD     -- console baudrate specified
#    LIVECD_CONSOLE_PARITY   -- console parity specified
#    LIVECD_CONSOLE_DATABITS -- console databits specified

[[ ${RC_GOT_FUNCTIONS} != "yes" ]] && [[ -e /etc/init.d/functions.sh ]] && source /etc/init.d/functions.sh

livecd_parse_opt() {
	case "$1" in
		*\=*)
			echo "$1" | cut -f2 -d=
		;;
	esac
}

livecd_get_cmdline() {
	echo "0" > /proc/sys/kernel/printk
	CMDLINE=$(cat /proc/cmdline)
	export CMDLINE
}

livecd_console_settings() {
	# scan for a valid baud rate
	case "$1" in
		300*)
			LIVECD_CONSOLE_BAUD=300
		;;
		600*)
			LIVECD_CONSOLE_BAUD=600
		;;
		1200*)
			LIVECD_CONSOLE_BAUD=1200
		;;
		2400*)
			LIVECD_CONSOLE_BAUD=2400
		;;
		4800*)
			LIVECD_CONSOLE_BAUD=4800
		;;
		9600*)
			LIVECD_CONSOLE_BAUD=9600
		;;
		14400*)
			LIVECD_CONSOLE_BAUD=14400
		;;
		19200*)
			LIVECD_CONSOLE_BAUD=19200
		;;
		28800*)
			LIVECD_CONSOLE_BAUD=28800
		;;
		38400*)
			LIVECD_CONSOLE_BAUD=38400
		;;
		57600*)
			LIVECD_CONSOLE_BAUD=57600
		;;
		115200*)
			LIVECD_CONSOLE_BAUD=115200
		;;
	esac
	if [ "${LIVECD_CONSOLE_BAUD}" = "" ]
	then
		# If it's a virtual console, set baud to 38400, if it's a serial
		# console, set it to 9600 (by default anyhow)
		case ${LIVECD_CONSOLE} in 
			tty[0-9])
				LIVECD_CONSOLE_BAUD=38400
			;;
			*)
				LIVECD_CONSOLE_BAUD=9600
			;;
		esac
	fi
	export LIVECD_CONSOLE_BAUD

	# scan for a valid parity
	# If the second to last byte is a [n,e,o] set parity
	local parity
	parity=$(echo $1 | rev | cut -b 2-2)
	case "$parity" in
		[neo])
			LIVECD_CONSOLE_PARITY=$parity
		;;
	esac
	export LIVECD_CONSOLE_PARITY	

	# scan for databits
	# Only set databits if second to last character is parity
	if [ "${LIVECD_CONSOLE_PARITY}" != "" ]
	then
		LIVECD_CONSOLE_DATABITS=$(echo $1 | rev | cut -b 1)
	fi
	export LIVECD_CONSOLE_DATABITS
	return 0
}

livecd_read_commandline() {
	livecd_get_cmdline || return 1

	for x in ${CMDLINE}
	do
		case "${x}" in
			cdroot)
				CDBOOT="yes"
				RC_NO_UMOUNTS="^(/|/dev|/dev/pts|/lib/rcscripts/init.d|/proc|/proc/.*|/sys|/mnt/livecd|/newroot)$"
				export CDBOOT RC_NO_UMOUNTS
			;;
			cdroot\=*)
				CDBOOT="yes"
				RC_NO_UMOUNTS="^(/|/dev|/dev/pts|/lib/rcscripts/init.d|/proc|/proc/.*|/sys|/mnt/livecd|/newroot)$"
				export CDBOOT RC_NO_UMOUNTS
			;;
			console\=*)
				local live_console
				live_console=$(livecd_parse_opt "${x}")

				# Parse the console line. No options specified if
				# no comma
				LIVECD_CONSOLE=$(echo ${live_console} | cut -f1 -d,)
				if [ "${LIVECD_CONSOLE}" = "" ]
				then
					# no options specified
					LIVECD_CONSOLE=${live_console}
				else
					# there are options, we need to parse them
					local livecd_console_opts
					livecd_console_opts=$(echo ${live_console} | cut -f2 -d,)
					livecd_console_settings  ${livecd_console_opts}
				fi
				export LIVECD_CONSOLE
			;;
			secureconsole)
				export SECURECONSOLE="yes"
			;;
		esac
	done
	return 0
}

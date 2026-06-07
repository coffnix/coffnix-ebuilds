echo 
cat /etc/vipnix/logo.ascii
echo
bash /etc/update-motd.d/30-vipnix-sysinfo

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export HISTTIMEFORMAT="%h/%d %H:%M:%S "
export HISTFILESIZE="1000000"
export HISTSIZE="1000000"

export PS1="(gentoo) $PS1"

export PAGER="less"

export EIX_LIMIT=0

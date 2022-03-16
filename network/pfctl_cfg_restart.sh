#!/bin/zsh

declare -A pfKVpr
declare cfgFileNm=/etc/pf.conf
declare tstFileNm=/var/tmp/tst.conf
declare fileNm=${cfgFileNm}
declare watchpid=0
declare watchpidfile=/var/run/pfctrl_cfg_restart.watchpid

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

ctrl_c() {
    echo "** Trapped CTRL-C"
    killbg
    echo "killing jobs: $(jobs -p)"
    kill $(jobs -p)
    exit
}

killbg()
{
    watchpid=$(cat $watchpidfile)
    if [ $watchpid -ne 0 ]; then
        echo "Killing tcpdump pid:($watchpid)"
        kill -9 ${watchpid}
        rm $watchpidfile
    fi

}

pfprint() {
  if [ -n "$1" ];then
    sudo pfctl -a "$2" -s"$1" 2>/dev/null
  else
    sudo pfctl -s"$1" 2>/dev/null
  fi
}

print_all() {

  local p=$(printf "%-40s" $1)
  (
    pfprint r "$1" | sed "s,^,r     ,"
    pfprint n "$1" | sed "s,^,n     ,"
    pfprint A "$1" | sed "s,^,A     ,"
  ) | sed "s,^,$p,"

  for a in `pfprint A "$1"`; do
    print_all "$a"
  done
}

lockStatus()
{
# echo "lstat"

    lstatus="unknown"
    if [[ $(grep -o '^# *block[ ]*all' /etc/pf.conf) ]]; then 
        lstatus="unblocked" 
    elif [[ $(grep -o '^ *block[ ]*all' /etc/pf.conf) ]]; then
        lstatus="blocked"
    fi

    echo $lstatus
}
 
test()
{ 
    # fix this in order to load from a temp file
    pfctl -v -n -f $fileNm
    return 1
}

makecfgchanges()
{
    block=$1
    if [ "$restartreq" -eq 0 ]; then
        echo "restartreq = $restartreq"
        return
    fi
    local res=$(lockStatus)
    echo "res = $res"
    if [ "$block" -eq 1 ]; then
        if [[ $(lockStatus) == "unblocked" ]]; then 
            echo "Block it"
             sed -i '' 's/^#block all/block all/g' $fileNm
        fi
    else 
        if [[ $(lockStatus) == "blocked" ]]; then
            echo "Unblocking IP Traffic"
             sed -i '' 's/^block all/#block all/g' $fileNm
        fi
    fi
}

reloadsettings()
{
    echo "ReloadSettings confirm the change request."
    makecfgchanges $1

#    while true; do
#        read "Confirm to load settings and restart: " yn
#        case ${yn} in
#            [Yy]*)
#                break;;
#            [Nn]*) 
#                echo "revertcfgchanges $1"
#                break;;
#            * )
#                echo "Undefined response ${yn}, use: y or n."
#                echo $yn
#        esac
#    done
    if [[ $test ]]; then
        test
    else
        pfctl -e -f ${fileNm}
        #pfctl -a 'com.apple/block' -f ${fileNm} -e
    fi

    return 1
}

info()
{
    echo "get pfctrl -s info"
    pfctl -s info
}

tcptail()
{
    # Originally inteded to leave this port open
    # for pflog
    echo "prior to tcpdump pid -> $!"
    tcpdump -v -n -e -ttt 2>/dev/null > /tmp/tcpdump_$$ & 
    echo "tcpdump pid -> $!"
    watchpid=$!
    echo $watchpid
}

showsettings()
{
    echo "showsettings"
    pfctl -vsA
    pfctl -sa
    print_all
}

show_help() 
{
    echo "Usage:

    ${0##*/}  [-h][-u][-b][-r][-i][-s][-t][-w][-q][-k]

Options:

    -h, --help
        display this help and exit

    -u, --unblock
        unblock all network traffic load, test and restart

    -b, --block
        block all network traffic load, test and restart
    
    -r, --restart
        restart pf.config with load and test
    
    -i, --info
        collection of packet and byte count statistics for the given
        interfacecurrently running detailed settings

    -s, --show
        show currently running detailed settings

    -t, --test new settings from pf.config file prior to enabling any changes
        debug run the install script libraries and dependencies
    
    -w, --watch 
        watch tcpdump with the currently activated settings in pf.config file 
    
    -q, --query-status 
        query whether it is currently blocked or unblocked

    -k, --kill 
        kill any background tails or tcpdumps
"
}

cfg_pfctlNetwork()
{
    OPTIND=1         # Reset in case getopts has been used previously in the shell.

    restartreq=0
    block=0
    unblock=0
    refresh=0
    test=0
    info=0
    watch=0
    settings=0
    kill=0
#    echo "args in; ${@}"

    while getopts "h?ubrtiwsiqk" opt; 
    do
        case "$opt" in

        h|\?)
            show_help
            exit 0
            ;;
    
        u)
            echo "Unblocking All Traffic"
            unblock=1
            restartreq=1
            ;;
    
        b)
            echo "Blocking All Traffic"
            block=1
            restartreq=1
            ;;
    
        r)
            echo "Reload configs with force flag set"
            refresh=1
            ;;
    
        t)
            echo "Test the changed configs without actually loading the settings."
            test=1
            restartreq=0
            cp $fileNm $tstFileNm
            fileNm=$tstFileNm
            # Test the settings
            ;;
        
        i)
            echo "Info Stats on Packets"
            info=1
            ;;
        w)
            echo "Watch the TCP Dump"
            watch=1
            ;;
        
        s)
            echo "Display settings"
            settings=1
            ;;
        
        q)
            local res=$(lockStatus)
            echo $res
            ;;

        k)
            echo "Kill background processes\n\tTCP Dump pid:\t$(cat $watchpidfile)\n\t"
            kill=1
            ;;
    
        esac
    done
    
    shift $((OPTIND-1))
    [ "${1:-}" = "--" ] && shift
    
    if [ $watch -eq 1 ]; then
        echo "watch output file: /tmp/watch_output_$$"
        tcptail
        echo "tcptail fnc call: watchpid=$!"
    elif [ $settings -eq 1 ]; then
        showsettings
    elif [ $info -eq 1 ]; then
        info
    elif [ $kill -eq 1 ]; then
        killbg
    fi
   
    echo "block = $block"
    echo "unblock = $unblock"

    if [ $block -eq 1 ]; then
        reloadsettings $block 
    elif [ $unblock -eq 1 ]; then
        reloadsettings $block 
    fi

    if [ $settings -eq 1 ]; then
        showsettings
    fi

    if [[ $watchpid -ne 0 ]]; then
        echo "$watchpid to $watchpidfile"
        echo $watchpid > $watchpidfile
    fi

}

cfg_pfctlNetwork $@
echo "BYE"

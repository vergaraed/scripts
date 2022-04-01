#!/bin/bash

declare -A pfKVpr
declare cfgFileNm=/etc/pf.conf
declare cfgBlockAllFileNm=/etc/pf.eds.conf
declare cfgBlockListFileNm=/etc/pf.blocklist.conf

declare tstFileNm=/var/tmp/tst.conf
declare fileNm=${cfgFileNm}
declare watchpid=0
declare watchpidfile=/var/run/pfctrl_cfg_restart.watchpid
declare blockedlist=ipblocklist

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
        echo "remove watchpidfile $watchpidfile"
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
    pfprint T "$1" | sed "s,^,T     ,"
    pfprint n "$1" | sed "s,^,n     ,"
    pfprint A "$1" | sed "s,^,A     ,"
  ) | sed "s,^,$p,"

  for a in `pfprint A "$1"`; do
    print_all "$a"
  done
}

showblockedips()
{
    pfctl -t $blockedlist -T show
}

lockStatus()
{
    lstatus="unknown"

    showblockedips

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

info()
{
    echo "get pfctrl -s info"
    pfctl -s info
}

blockall()
{
    echo "blockall"
    if [[ $(lockStatus) == "unblocked" ]]; then
        echo "Block it"
        sed -i '' 's/^#block all/block all/g' $fileNm
    fi

}
unblockall()
{
    echo "unblockall"
    if [[ $(lockStatus) == "blocked" ]]; then                                        
        echo "Unblocking IP Traffic"
        sed -i '' 's/^block all/#block all/g' $fileNm
    fi
}


blockset()
{
    ip=$1
    echo "blockset $ip" 
    if [[ $ip == "all" ]]; then
        echo "blockall $ip"
        blockall
    else
        echo "blockset $ip"
        pfctl -t $blockedlist -T add $ip
        launchctl unload /Library/LaunchDaemons/macbook.blocklist.pf.plist
        launchctl load /Library/LaunchDaemons/macbook.blocklist.pf.plist
    fi
}

unblockset()
{
    IPDel=$1
    if [[ $IPDel == "all" ]];then        
        unblockall
    else 
        pfctl -t $blockedlist -T delete $IPDel
        launchctl unload /Library/LaunchDaemons/macbook.blocklist.pf.plist
        launchctl load /Library/LaunchDaemons/macbook.blocklist.pf.plist
    fi
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

    while getopts "h?u:b:rtiwsiqk" opt; 
    do
        case "$opt" in

        h|\?)
            show_help
            exit 0
            ;;
    
        u)
            IPDel=${OPTARG}
            echo "Unblocking All Traffic $IPDel"
            unblock=1
            echo "Unblocking $IPDel"
            restartreq=1
            ;;
    
        b)
            IPAdd=${OPTARG}
            echo "Blocking All Traffic $IPAdd"
            block=1
            echo "Blocking $IPDel"
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
        echo "watch output file: /tmp/tcpdump_$$"
        tcptail
        echo "tcptail fnc call: watchpid=$!"
    elif [ $settings -eq 1 ]; then
        showsettings
    elif [ $info -eq 1 ]; then
        info
    elif [ $kill -eq 1 ]; then
        killbg
    fi
   
    echo "block = $block ip=$IPAdd"
    echo "unblock = $unblock ip=$IPDel"

    if [ $block -eq 1 ]; then
        blockset $IPAdd
    elif [ $unblock -eq 1 ]; then
        unblockset $IPDel
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

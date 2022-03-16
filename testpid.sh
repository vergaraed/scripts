#!/bin/zsh


testfun() 
{
    echo "testfnc \$\$=$$ \$BASHPID=$BASHPID"; 
    echo "\$\!=$!";
    . ~/.alias;

    sweep &;
    echo "sweep tstfun \$\$=$$ \$BASHPID=$BASHPID";
    echo "sweep tstfun \$\!=$!";


    ps -ef | grep "$!";
    ps -ef | grep "$$";
    sleep 5;
    ps -ef | grep -e sweep;

}; 

echo "my pid is $$"; 

testfun & 
echo "in main called tstfun";
echo "main \$\$=$$ \$BASHPID=$BASHPID";
echo "main \$\!=$!";
echo "main wait";
wait "$$" "$!"
echo "done wait";


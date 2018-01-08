#!/bin/bash
#loadavg.sh - selectively SIG stop/start given program(s) based upon system load.
#Trivial shell script by Shawn Holwegner.
#Yes, I use too many bashisms here, and have some odd ways of working with GNU
#and BSD format tools to avoid issues with data (floating point vs none, et al).
#Defaults to Distributed.net client, with a load of 1.00 (per CPU under Linux), 10
#seconds refresh.  Please feel free to suggest additions/changes/etc.
PATH=/bin:/sbin:/usr/bin:/usr/sbin
OS=`uname -s`
DONOW=0
QUIET=0
PROGNAME=0
while [[ $# -ge 1 ]]; do
  case $1 in
    -e|--exe)
      shift
      PROGNAMEtmp="$1"
      shift
      ;;
    -l|--limit)
      shift
      MAXLOADtmp="$1"
      shift
      ;;
    -r|--refresh)
      shift
      SLEEPtmp="$1"
      shift
      ;;
    -q|--quiet)
      QUIET="y"
      shift
      ;;
    *)
      echo -ne " Usage:\n\t$0\t -e/--exe (programname) -l/--limit (average load limit) -r/--refresh (how often to refresh current load) -q/--quiet\n\n"
      exit 1;
      ;;
  esac
done
if [ "x"$PROGNAMEtmp != "x" ]; then
  PROGNAME=$PROGNAMEtmp
  unset PROGNAMEtmp
  else
  PROGNAME='dnetc'
fi
if [ "x"$MAXLOADtmp != "x" ]; then
  MAXLOAD=`echo $MAXLOADtmp * 100 | bc | cut -f1 -d\.`
  unset MAXLOADtmp
  else
    if [ $OS"x" = "Linuxx" ]; then
      NUMCPUS=`grep processor /proc/cpuinfo | wc -l`
      MAXLOAD=`echo $NUMCPUS" * 100" | bc`
    else
      MAXLOAD=100
    fi
fi 
if [ "x"$SLEEPtmp != "x" ]; then
  SLEEP=$SLEEPtmp
  unset SLEEPtmp
else
  SLEEP=10
fi 
if [ "x"$OS == "xLinux" ]; then
  PSFLAGS="-ax"
elif [ "x"$OS"x" == "xSunOS" ]; then
  PSFLAGS="-ef"
else
  PSFLAGS="ax"
fi
while true; do
  if [ $OS"x" == "Linuxx" ]; then
    MYPIDS=`pidof $PROGNAME`
  else
    MYPIDS=`ps $PSFLAGS | grep "$PROGNAME" | grep -v grep | cut -f1 -d' '`
  fi
  if [ $OS"x" = "Linuxx" ]; then
    LOAD=`awk '{printf "%1.2f", $1}' /proc/loadavg`
    #Wasted pipes just to pretty print.
    CURLOAD=`awk '{printf "%1d", $1 * 100}' /proc/loadavg`
  else
    LOAD=`uptime | sed 's/.*averages:\ //' | tail -1 | cut -f1 -d\,`
    CURLOAD=`echo $LOAD" * 100" | bc | cut -f1 -d\.`
  fi
  if [ $CURLOAD -gt $MAXLOAD ]; then
    if [ $QUIET"x" == "0x" ]; then 
      echo -n "Load of $LOAD is over $MAXLOAD, stopping"
    fi
    for PIDS in $MYPIDS; do
      if [ $QUIET"x" == "0x" ]; then 
        echo -n " $PIDS"
      fi
      kill -s STOP $PIDS
    done
    if [ $QUIET"x" == "0x" ]; then 
      echo "."
    fi
    DID=1
  else
    if [ $QUIET"x" == "0x" ]; then 
      echo -n "Load of $LOAD is good, enabling:"
    fi
    for PIDS in $MYPIDS; do
      if [ $QUIET"x" == "0x" ]; then 
        echo -n " $PIDS"
      fi
      kill -s CONT $PIDS
    done
    if [ $QUIET"x" == "0x" ]; then 
      echo "."
    fi
    DID=2
  fi
sleep $SLEEP
done

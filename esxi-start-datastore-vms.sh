#!/bin/sh
################################################################################
#
# Command-line parameters: --none--
#
# Start specific guest virtual machines
#
################################################################################

# Edit to suit your needs and environment

. /mnt/tank/systems/scripts/host.config

is_active=0
logfile=${logdir}/esxi-start-datastore-vms.log
waitdelay=30

if [ $is_active -ne 0 ]; then
  echo "Pausing $waitdelay seconds before starting virtual machines..." >> $logfile
  sleep $waitdelay
  
  if [ "${freenashost}" = "boomer" ]; then
    /mnt/tank/systems/scripts/esxi-start-vm.sh root felix adonis  >> $logfile
    /mnt/tank/systems/scripts/esxi-start-vm.sh root felix aphrodite  >> $logfile
  fi
fi


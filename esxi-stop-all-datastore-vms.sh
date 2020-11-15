#!/bin/sh
################################################################################
#
# Command-line parameters: user_id esxi_host_name datastore_name
#
# Gracefully powers down all guest virtual machines in a particular datastore (datastore_name)
# on remote VMware ESXi server (esxi_host_name) using given user credentials (user_id).
#
################################################################################

# Check for invocation errors

if [ $# -ne 3 ]; then
  echo "$0: error! Not enough arguments"
  echo "Usage is: $0 user_id esxi_host_name datastore_name"
  exit 1
fi

. /mnt/tank/systems/scripts/esxi.config

# Gather command-line arguments for user ID, hostname, and datastore name:

esxiuser=$1
esxihost=$2
# ESXi datastore must be uppercase:
#esxidatastore=$(echo "$3" | tr '[:lower:]' '[:upper:]')
#November 2020: no longer seems to be the case, just assign the user's datastore name 'as is':
esxidatastore=$3

################################################################################
#
# Action begins here
#
################################################################################

echo "$(date): $0 ${esxiuser}@${esxihost} datastore=${esxidatastore} (max wait time=${maxwait}s"
echo "Full list of VM guests on this server:"
ssh "${esxiuser}"@"${esxihost}" vim-cmd vmsvc/getallvms

echo "VM guests on datastore ${esxidatastore}:"
ssh "${esxiuser}"@"${esxihost}" vim-cmd vmsvc/getallvms | grep "\[${esxidatastore}\]"

# Get server IDs for all VMs stored on the indicated datastore. These IDs change between
# boots of the ESXi server, so we have to work from a fresh list every time. We are only
# interested in the guests stored in '[DATASTORE]' and the brackets are important.

guestvmids=$(ssh "${esxiuser}"@"${esxihost}" vim-cmd vmsvc/getallvms | grep "\[${esxidatastore}\]" | awk '$1 ~ /^[0-9]+$/ {print $1}')

# Iterate over the list of guest VMs, shutting down any that are powered up

for guestvmid in $guestvmids; do
  totalvms=$((totalvms + 1))
  shutdown_guest_vm "$guestvmid"
done

echo "Found ${totalvms} virtual machine guests on ${esxihost} datastore ${esxidatastore}"
echo "   Total shut down: ${totalvmsshutdown}" 
echo "Total powered down: ${totalvmspowereddown}" 
echo "$(date): $0 completed"


#!/bin/sh
################################################################################
#
# Command-line parameters: user_id esxi_host_name vmx_base_filename
#
# Stop guest virtual machine with vmx file (vmx_base_filename'.vmx') on remote
# VMware ESXi server (esxi_host_name) using given user credentials (user_id)
#
################################################################################

# Check for invocation errors

if [ $# -ne 3 ]; then
  echo "$0: error! Not enough arguments"
  echo "Usage is: $0 user_id esxi_host_name vmx_filename"
  echo "Only specify the vmx basefilename; leave off the '.vmx' extension"
  exit 1
fi

. /mnt/tank/systems/scripts/esxi.config

# Gather command-line arguments for user ID, hostname, and datastore name:

esxiuser=$1
esxihost=$2
vmxname=$3

guestvmids=$(ssh "${esxiuser}"@"${esxihost}" vim-cmd vmsvc/getallvms | grep "/${vmxname}.vmx" | awk '$1 ~ /^[0-9]+$/ {print $1}')

echo "$(date): $0 ${esxiuser}@${esxihost} vmx=${vmxname}.vmx"

for guestvmid in $guestvmids; do
  shutdown_guest_vm "$guestvmid"
done


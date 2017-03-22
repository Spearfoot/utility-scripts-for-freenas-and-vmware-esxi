#!/bin/sh
################################################################################
#
# Command-line parameters: --none--
#
# Gracefully powers down all guest virtual machines in the FreeNAS datastores
#
################################################################################

. /mnt/tank/systems/scripts/host.config

logfile=${logdir}/esxi-stop-all-vms.log

echo "$(date): Shut down virtual machines on ESXi host ${esxihost}, FreeNAS server ${freenashost}" | tee ${logfile}

for datastore in $datastores; do
  /mnt/tank/systems/scripts/esxi-stop-all-datastore-vms.sh root ${esxihost} ${datastore} >> ${logfile}
done


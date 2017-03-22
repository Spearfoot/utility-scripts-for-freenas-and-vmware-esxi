# All-In-One utility scripts for FreeNAS and VMware ESXi 
A set of POSIX-compliant shell scripts for use with FreeNAS and VMware ESXi.

An All-In-One (AIO) system is a hypervisor with a NAS virtual machine (VM) providing data storage for additional VMs. My AIO systems consist of FreeNAS 9.10.x running as a virtual machine (VM) on VMware ESXi 6.0, with direct control of the system's hard drives passed through to the FreeNAS VM via VT-d. ESXi and the FreeNAS VM boot from a local datastore, with FreeNAS providing block or NFS-based datastores for additional VMs. 

Everyone crazy enough to build an AIO ends up asking the same questions: 

* Datastores provided by FreeNAS aren't available until after it boots up... how do I make the ESXi host see them?
* How do I reliably start VMs based on the FreeNAS datastores?
* How do I make sure the VMs based on FreeNAS are shut down gracefully when the FreeNAS VM shuts down?
* I'm using a UPS... how do I make sure everything gets shut down gracefully when the power goes offline?

These are scripts I wrote specifically to address these issues in the context of FreeNAS and ESXi, but the concepts and techniques involved may be useful in other situations as well.

At startup, it is necessary to force the ESXi host to rescan its datastores so that the FreeNAS datastores and the VMs based on them will become available for execution. It may also be desirable for FreeNAS itself to start selected VMs when it boots. Why? Because of timing issues. In the normal course of operations you may stop and restart the FreeNAS VM without restarting the ESXi host. Think of applying updates or making other changes that require a reboot. This means you can't really rely on the ESXi host to start and stop the FreeNAS-based VMs. The same timing issues apply at shutdown. Therefore, IMHO, it's best to let FreeNAS shut down the VMs it provides.

I configure FreeNAS to monitor the UPS and shut the AIO system down if the power goes off-line. FreeNAS issues a `poweroff` command to the ESXi host when the power goes offline long enough for the UPS service to trigger a shutdown. Before powering down, the ESXi host shuts down all of its running VMs, including FreeNAS. 

In practice, I use these scripts in two places on the FreeNAS VM: `startup-script.sh` and `shutdown-script.sh`, configured respectively as postinit and shutdown tasks:
![alt text](https://github.com/Spearfoot/utility-scripts-for-freenas-and-vmware-esxi/blob/master/freenas-task-setup.jpg)

Requirements:
* The SSH service must be enabled on the ESXi host and public key logons configured from the FreeNAS VM where you wish to execute the scripts.
* The VMware Tools or equivalent (e.g., Open VM Tools) must be installed on all VMs. This enables the ESXi host to gracefully shut down the VMs when necessary.
* The scripts are configured to live in a directory named /mnt/tank/systems/scripts - you will need to edit them to match their location on your system.
* You will need to edit the host.config and esxi.config files to suit your environment.

***
# esxi-poweroff-host.sh
Issues a `poweroff` command to the ESXi host.

ESXi versions 4.x/5.x/6.x can be gracefully shut down simply by executing the [poweroff command](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1013193). The ESXi host will shut down any running VMs before shutting down itself.

FreeNAS users should note that the [Network UPS Tools](http://networkupstools.org/) daemon is unable to execute this script because of permissions issues. So just specify the SSH command - `ssh root@esxihostname poweroff` - as the UPS Shutdown command.
***
# esxi-rescan-datastores.sh
Instructs the ESXi host to rescan its datastores.

Call from your FreeNAS startup script.
***
# esxi-start-datastore-vms.sh
Start selected virtual machines.

An example showing how to start selected VMs.
***
# esxi-start-vm.sh
Start a virtual machine given its vmx name.
***
# esxi-stop-all-datastore-vms.sh
Gracefully shut down all running VMs in a given datastore.
***
# esxi-stop-all-vms.sh
Shut down all virtual machines on datastores provided by FreeNAS.
***
# esxi-stop-vm.sh
Shut down a virtual machine given its vmx name.
***
# startup-script.sh
Sample startup script for use as a FreeNAS postinit Init/Shutdown Task.
***
# shutdown-script.sh
Sample shutdown script for use as a FreeNAS shutdown Init/Shutdown Task.



#! /bin/bash
#################################
### Detect the partition to which logs files are written had become full ####

#Function to start the service if the desired states are met.
restart_audit_service () {
if [ -f /etc/init.d/auditd ]; then
    sudo /etc/init.d/auditd stop; sudo /etc/init.d/auditd start
else
    sudo /sbin/service auditd stop
    sudo /sbin/service auditd start
fi                                                                                                                                                                      }

sudo grep -i disk_full_action /etc/audit/auditd.conf
if [ $? -eq 0 ]
then
    Audit_Pram=$(sudo grep -i "disk_full_action" /etc/audit/auditd.conf | awk '{ print $3 }')
    if [ $Audit_Pram == single ]
    then
        echo "Line was set as per the policy: `sudo grep -i disk_full_action /etc/audit/auditd.conf`"
    else
        sudo sed -i 's/disk_full_action = .*/disk_full_action = single/g' /etc/audit/auditd.conf
        echo "Line is set as per the policy: `sudo grep -i disk_full_action /etc/audit/auditd.conf`"
        restart_audit_service
    fi
else
   sudo sed -i 's/disk_full_action = .*/disk_full_action = single/g' /etc/audit/auditd.conf
   echo "Line is set as per the policy: `sudo grep -i disk_full_action /etc/audit/auditd.conf`"
   restart_audit_servcie
fi
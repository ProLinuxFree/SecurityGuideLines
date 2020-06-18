#! /bin/bash
#Color Scheme for the Echo Out Put#
#RED='\033[0;31m'
#Green='\033[0;32m'
#NC='\033[0m' # No Color
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
##############################################################################################################################################################

#Check the Server Name and if where we are going to install the RPM and the configuration as per the Security GuideLines.
echo "********************************************************************************************************************************************************"
Host_Name=$(/usr/bin/hostname -f)
Host_IP=$(ip a | grep "scope global" | grep -Po '(?<=inet )[\d.]+')
echo "${green} $Host_Name : $Host_IP ${reset}"
echo "********************************************************************************************************************************************************"

echo "GConf2 package installation required for the job OL6-00-000257 - The Graphical Desktop Environment Must Set the Idle Timeout to No More than 15 Minutes"
echo "********************************************************************************************************************************************************"
rpm_out=$(rpm -qa | grep -i Gconf2 | cut -c1-6)
if [ "$rpm_out" == "GConf2" ]
then 
    echo  "${green} $rpm_out is installed ${reset}"
else
    sudo yum install GConf2 -y > /dev/null 2>&1
    echo  "${green} $(rpm -qa | grep -i Gconf2 | cut -c1-6) is now installed ${reset}"
fi
echo "********************************************************************************************************************************************************"

echo "OL6-00-000257 - The Graphical Desktop Environment Must Set the Idle Timeout to No More than 15 Minutes"
echo "********************************************************************************************************************************************************"
sudo grep -i 15 /etc/gconf/gconf.xml.mandatory/desktop/gnome/session/%gconf.xml > /dev/null 2>&1

if [ $? -eq 0 ]
then 
     echo "${green} Session lock is set for 15 mins ${reset}"
else
     sudo gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type int --set /desktop/gnome/session/idle_delay 15 > /dev/null 2>&1
     echo  "${green} The Idle Timeout is set to: `grep -i 15 /etc/gconf/gconf.xml.mandatory/desktop/gnome/session/%gconf.xml` ${reset}"
     
fi
echo "*******************************************************************************************************************************************************"

echo "OL6-00-000324 - A Login Banner Must Be Displayed Immediately Prior to, or as Part of,Graphical Desktop Environment Login Prompts"
echo "*******************************************************************************************************************************************************"
sudo grep -i blank-only /etc/gconf/gconf.xml.mandatory/apps/gnome-screensaver/%gconf.xml > /dev/null 2>&1
if [ $? -eq 0 ]	
then 
     echo "${green} screensaver mode is blank-only ${reset}"
else 
     sudo gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type string --set /apps/gnome-screensaver/mode blank-only > /dev/null 2>&1
     echo  "${green} ScreenSaver mode is set to: `sudo grep -i blank-only /etc/gconf/gconf.xml.mandatory/apps/gnome-screensaver/%gconf.xml` ${reset}"
     
fi
echo "******************************************************************************************************************************************************"


echo "RHEL-07-010082 - The Operating System Must Set the Session Idle Delay Setting for All"
echo "******************************************************************************************************************************************************"
if [ $(egrep -i "centos|redhat" /etc/redhat-release | cut  -d " " -f 1) == "Red" ]
then 
systemDBs=`/bin/awk -F# '{print $1}' /etc/dconf/profile/user 2>/dev/null | /bin/awk -F: '$1 ~ /^[\ \t]*system-db/ {print $2}'`
for db in $systemDBs
 do 
  echo "/org/gnome/desktop/session/idle-delay" >> $(/bin/echo "/etc/dconf/db/"$db".d/locks/*")
 done
else
     echo "${green} This is Not A Red Hat Server, So skipping the Job=RHEL-07-010082 ${reset}"
fi
echo "******************************************************************************************************************************************************"

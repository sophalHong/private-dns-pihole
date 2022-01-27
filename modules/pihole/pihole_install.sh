#!/bin/bash -ex
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
[[ -x "$(command -v setenforce)" ]] && setenforce 0

mkdir -p /etc/pihole/
mkdir -p /var/run/pihole

# Preseed variables to assist with using --unattended install
setupVars=/etc/pihole/setupVars.conf
{
  echo "PIHOLE_INTERFACE=eth0"
  echo "IPV4_ADDRESS=0.0.0.0"
  echo "IPV6_ADDRESS=0:0:0:0:0:0"
  echo "PIHOLE_DNS_1=8.8.8.8"
  echo "PIHOLE_DNS_2=1.0.0.1"
  echo "QUERY_LOGGING=true"
  echo "INSTALL_WEB_SERVER=true"
  echo "INSTALL_WEB_INTERFACE=true"
  echo "LIGHTTPD_ENABLED=true"
}>> "$setupVars"
source $setupVars

export USER=pihole

export PIHOLE_SKIP_OS_CHECK=true

# Run the installer in unattended mode using the preseeded variables above 
curl -sSL https://install.pi-hole.net | bash -sex -- --unattended
/usr/local/bin/pihole -a -p ${web_password}

touch /tmp/finished-user-data
echo 'Pihole install successful'

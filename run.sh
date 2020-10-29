#!/bin/bash

set -ex

source /etc/network.cfg
sed -ri 's/^(manage_dhcp: ).*/\11/' /etc/cobbler/settings
sed -ri "s/^(next_server: ).*/\1$MYIP/" /etc/cobbler/settings
sed -ri "s/^(server: ).*/\1$MYIP/" /etc/cobbler/settings

sed -ri "s/192.168.1.0/$SUBNET/" /etc/cobbler/dhcp.template
sed -ri "s/255.255.255.0/$NETMASK/" /etc/cobbler/dhcp.template
sed -ri "s/192.168.1.5/$GWIP/" /etc/cobbler/dhcp.template
sed -ri "s/192.168.1.1/$GWIP/" /etc/cobbler/dhcp.template
sed -ri "s/192.168.1.100/$STARTIP/" /etc/cobbler/dhcp.template
sed -ri "s/192.168.1.254/$ENDIP/" /etc/cobbler/dhcp.template
systemctl restart cobblerd
sleep 10s

cobbler import --arch=x86_64 --path=/mnt/ --name=YourSystem
#cobbler profile edit --name=YourSystem-x86_64 --repos="kernel" --kickstart=/var/lib/cobbler/kickstarts/YourKS.ks
cobbler profile edit --name=YourSystem-x86_64 --kickstart=/var/lib/cobbler/kickstarts/YourKS.ks

cat /etc/cobbler.cfg | grep 'flag' > /etc/hosts.cfg

while read line
do
    namelong=$(echo $line | cut -d " " -f 3)
    nameshort=$(echo $line | cut -d " " -f 3 | cut -d "." -f 1)
    ip=$(echo $line | cut -d " " -f 1)
    mac=$(echo $line | cut -d " " -f 4)
    cobbler system add --name=$nameshort --profile=YourSystem-x86_64 \
    --mac-address=$mac --ip-address=$ip --netboot-enabled=1  \
    --interface=$IFACE --static=1 --hostname=$nameshort \
    --if-gateway=$GWIP --netmask=$NETMASK \
    --name-servers="$DNSIP 114.114.114.114" \
    --name-servers-search="$DOMAIN"
done < /etc/hosts.cfg

cobbler sync
sed -i '/^        filename/d' /etc/dhcp/dhcpd.conf
systemctl restart dhcpd

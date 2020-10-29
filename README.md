# File tree
## cobbler needed files
* mnt: mount iso file in mnt directory, centos only e.g.mount ~/centos7.iso mnt
* file/loaders.tar.gz: boot loaders for BIOS and UEFI
* kickstarts: redhat kickstart files, default is YourKS.ks
* snippets: included in kickstart file, installing shell scripts

## files for convenient
* Dockerfile: cobbler in docker
* file/test(.pub): rsa key pub for ~/.ssh/authorized_keys

## files for configure
* network.cfg: 
  * GWIP: gateway ip
  * MYIP: IP running cobbler
  * SUBNET: subnet for dhcp
  * NETMASK
  * DOMAIN: used in FQDN, e.g. node100-100(host).example.cluster(cluster)
  * DNSIP: coredns IP to resolv FQDN in cluster
  * STARTIP, ENDIP: for dhcp
* hosts.cfg:
  * as config of cobbler, coredns, ansible
  * primary-master: node100-100.sechnic1.cluster #cobbler-flag 192.168.100.100 00:00:00:22:22:20
    * node100-100.sechnic1.cluster: FQDN, shouldn't use ip
    * #cobbler-flag: flag string used by run.sh, followed by IP and MAC
  * nodes:
    * same as master, but maybe a label=node-role.kubernetes.io/infra= before cobblerflag, default compute label if not specify

## run.sh
* 5-17: config settings and dncp.template file with network.cfg
* 22: import iso file from /mnt dictionary(in container)
* 24: edit profile to specify default kickstart
* 26: filter lines has cobbler-flag
* 27-39: add system(machine to install the ios)
* 41: sync config
* 42: filename is the bootloaer for the system, if not deleted, UEFI boot not work
* 43: restart dhcpd

## cmd
* 3-19: rm, build, run, exec run.sh the cobbler image
* 22: copy hosts.cfg to ./file/
* 23: copy hosts.cfg to ../ansible
* 24-25: build and save dns image to tar file
* then: copy dns.tar to DNS_IP, load it and run it 

## debug
* http://192.168.234.203/cblr/svc/op/ks/system/node100-100 to see kickstart file right or not

## mirror
* registry-1.docker.io can be used by {"registry-mirrors": [""]}
* other like gcr.io can be used by docker pull 192.168.100.100/apiserver:xxx or dns gcr.io to 192.168.100.100 then pull gcr.io/apiserver:xxx

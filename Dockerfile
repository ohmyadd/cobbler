FROM centos:7

# install
RUN yum -y install epel-release \
    && yum -y install \
        cobbler \
        cobbler-web \
        dhcp \
# lead to dbus failed
#       bind \
        syslinux \
        pykickstart \
        patch \
        file \
        initscripts \
        xinetd \
    && yum clean all

# config, default password: toor
RUN sed -i -e 's/\(default_password_crypted: \).*/\1"$1$add$BbUCOLxomSeQSjcHuwYQT"/' /etc/cobbler/settings \
    # manage_dhcp: 1
    && sed -i -e 's/^\(manage_dhcp: \).*/\11/' /etc/cobbler/settings \
    # no init loop
#    && sed -i -e 's/^\(pxe_just_once: \).*/\11/' /etc/cobbler/settings \
    # manage_rsync: 1
    && sed -i -e 's/^\(manage_rsync: \).*/\11/' /etc/cobbler/settings \
    # tftp/ disable=no
    && sed -i -e 's/\(.*disable.*=\) yes/\1 no/' /etc/xinetd.d/tftp \
    && touch /etc/xinetd.d/rsync \
    && ln -sf "/usr/share/zoneinfo/Asia/Shanghai" /etc/localtime \
    # autostart & backup
    && systemctl enable cobblerd httpd dhcpd rsyncd.service



EXPOSE 69/udp 80 443 25151

WORKDIR /root/
ADD run.sh /root
ADD file/loaders.tar.gz /var/lib/cobbler/
CMD ["/usr/sbin/init"]

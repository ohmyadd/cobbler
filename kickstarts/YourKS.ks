# kickstart template for Fedora 8 and later.
# (includes %end blocks)
# do not use with earlier distros

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# Use text mode install
text
# Firewall configuration
firewall --enabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot
#ignoredisk --only-use=sda

#Root password
rootpw --plaintext toor
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# System bootloader configuration
#bootloader --location=partition --driveorder=sda
bootloader --location=mbr
# Partition clearing information
#clearpart --all --initlabel

# Allow anaconda to partition the system as needed
#autopart

# part start
part /boot/efi  --onpart=/dev/sda1
part / --onpart=/dev/sda2
# part /data1 --onpart=/dev/sda3
# part /data2 --onpart=/dev/sdb1


%pre
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 2048s 512M
parted -s /dev/sda set 1 boot on
mkfs.vfat -F32 /dev/sda1
parted -s /dev/sda mkpart primary 512M 100%
mkfs.xfs /dev/sda2
# parted -s /dev/sda mkpart primary 100G 100%
# mkfs.xfs /dev/sda3

parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary 0% 100%
mkfs.xfs /dev/sdb1
%end
# part end

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('pre_install_network_config')
%end

%packages
@core
%end

%post --nochroot
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('post_install_mtenance_publickey')
$SNIPPET('my_network_config')
%end

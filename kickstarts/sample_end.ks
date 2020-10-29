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
ignoredisk --only-use=sda

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
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Allow anaconda to partition the system as needed
#autopart
part /boot/efi --fstype="efi" --ondisk=sda --size=1024 --recommended
part / --fstype="xfs" --ondisk=sda --size=10240

%pre
parted -s /dev/sda mklabel gpt
%end

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
$SNIPPET('install_kernel_ml')
%end


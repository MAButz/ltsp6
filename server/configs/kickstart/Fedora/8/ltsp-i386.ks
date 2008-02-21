# Kickstart Definition for Client Chroot for i386

# we are going to install into a chroot, such as /opt/ltps/i386
install

# rev #2 will be configurable (i.e. http or ftp or cdrom/dvd or nfs, etc, etc)
repo --name=released --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-8&arch=i386
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f8&arch=i386

# this is just garbage, it is not used, but if left empty the user is prompted
rootpw --iscrypted $1$7RBvKHQ2$gozxTbUdO9.xBncKZQ9760

# should be selectable...
lang en_US
keyboard us
firewall --enabled --port=22:tcp
network --bootproto=dhcp --device=eth0
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc America/Los_Angeles

# cookie-cutter stuff from here
bootloader --location=none
# The following is the partition information you requested
# Note that any partitions you deleted are not expressed
# here so unless you clear all partitions first, this is
# not guaranteed to work
#clearpart --linux
reboot

#%post 
# NOTE! this running in the client chroot (/opt/ltsp), 
#       not on the server's root
#/sbin/ltsp-client-configure

# this could probably be slimmed-down quite a bit
%packages --excludedocs
#ltsp-client
aspell
aspell-en
atk
audit-libs
audit-libs-python
basesystem
bash
beecrypt
bitmap-fonts
bzip2-libs
cairo
chkconfig
chkfontpath
coreutils
cpio
cpp
cracklib
cracklib-dicts
cups-libs
cyrus-sasl-lib
db4
dbus
dejavu-fonts
device-mapper
diffutils
dmraid
e2fsprogs
e2fsprogs-libs
pulseaudio-esound-compat
elfutils-libelf
ethtool
expat
fedora-release
fedora-release-notes
filesystem
findutils
fontconfig
freetype
gawk
gdbm
glib2
glibc.i386
glibc-common
gnutls
gphoto2
grep
gzip
hpijs
hwdata
info
initscripts
iproute
iputils
kernel.i586
kernel-headers
kpartx
krb5-libs
kudzu
less
libacl
libattr
libcap
libdmx
libdrm
libexif
libfontenc
libFS
libgcc
libgcrypt
libgpg-error
libICE
libieee1284
libjpeg
libpng
libsane-hpaio
libselinux
libselinux-python
libsemanage
libsepol
libSM
libstdc++
libtermcap
libtiff
libusb
libuser
libX11
libXau
libXaw
libXdmcp
libXext
libXfont
libXfontcache
libXft
libXi
libXinerama
libxkbfile
libxml2
libxml2-python
libXmu
libXpm
libXrandr
libXrender
libXt
libXTrap
libXtst
libXv
libXxf86dga
libXxf86misc
libXxf86vm
lockdev
lvm2
MAKEDEV
mcstrans
mesa-libGL
mingetty
mkinitrd
mktemp
module-init-tools
nash
nc
ncurses
neon
net-snmp-libs
net-tools
openldap
openssh
openssl.i386
pam
passwd
pcre
perl
popt
rpcbind
procps
psmisc
python
python-sqlite2
python-urlgrabber
readline
redhat-lsb
rpm
rpm-libs
rpm-python
sane-backends
sane-backends-libs
sed
setup
shadow-utils
sqlite
rsyslog
system-config-display
sysvinit
tar
termcap
ttmkfdir
tzdata
udev
util-linux-ng
xkeyboard-config
xorg-x11-drv-acecad
xorg-x11-drv-aiptek
xorg-x11-drv-amd
xorg-x11-drv-apm
xorg-x11-drv-ark
xorg-x11-drv-ast
xorg-x11-drv-ati
xorg-x11-drv-calcomp
xorg-x11-drv-chips
xorg-x11-drv-cirrus
xorg-x11-drv-citron
xorg-x11-drv-cyrix
xorg-x11-drv-digitaledge
xorg-x11-drv-dmc
xorg-x11-drv-dummy
xorg-x11-drv-dynapro
xorg-x11-drv-elographics
xorg-x11-drv-evdev
xorg-x11-drv-fbdev
xorg-x11-drv-fpit
xorg-x11-drv-glint
xorg-x11-drv-hyperpen
xorg-x11-drv-i128
xorg-x11-drv-i740
xorg-x11-drv-i810
xorg-x11-drv-jamstudio
xorg-x11-drv-keyboard
xorg-x11-drv-magellan
xorg-x11-drv-magictouch
xorg-x11-drv-mga
xorg-x11-drv-microtouch
xorg-x11-drv-mouse
xorg-x11-drv-mutouch
xorg-x11-drv-neomagic
xorg-x11-drv-nsc
xorg-x11-drv-nv
xorg-x11-drv-palmax
xorg-x11-drv-penmount
xorg-x11-drv-rendition
xorg-x11-drv-s3
xorg-x11-drv-s3virge
xorg-x11-drv-savage
xorg-x11-drv-siliconmotion
xorg-x11-drv-sis
xorg-x11-drv-sisusb
xorg-x11-drv-spaceorb
xorg-x11-drv-summa
xorg-x11-drv-tdfx
xorg-x11-drv-tek4957
xorg-x11-drv-trident
xorg-x11-drv-tseng
xorg-x11-drv-ur98
xorg-x11-drv-v4l
xorg-x11-drv-vesa
xorg-x11-drv-via
xorg-x11-drv-vmmouse
xorg-x11-drv-vmware
xorg-x11-drv-void
xorg-x11-drv-voodoo
xorg-x11-fonts-100dpi
xorg-x11-server-utils
xorg-x11-server-Xorg
xorg-x11-xauth
xorg-x11-xfs
xorg-x11-xkb-utils
ypbind
yp-tools
yum
yum-metadata-parser
zlib
-acl
-acpid
-alsa-lib
-alsa-lib-devel
-anacron
-apmd
-aspell
-aspell-en
-at 
-audiofile
-audiofile-devel
-authconfig
-autofs
-bc
-bind-libs
-bind-utils
-binutils
-bluez-gnome
-bluez-libs
-bluez-utils
-bzip2
-ccid
-comps-extras
-coolkey
-cpuspeed
-crash
-crontabs
-cryptsetup-luks
-cups
-curl
-cyrus-sasl
-cyrus-sasl-plain
-dbus-glib
-dbus-python
-desktop-file-utils
-device-mapper-multipath
-dhclient
-dhcp
-dmidecode
-dos2unix
-dosfstools
-dump
-ed
-eject
-fbset
-fedora-logos
-file
-finger
-firstboot-tui
-freetype-devel
-ftp
-GConf2
-gettext
-gnome-mime-data
-gnupg
-gpm
-groff
-grub
-gtk2
-hal
-hdparm
-hesiod
-htmlview
-ifd-egate
-ipsec-tools
-iptables
-iptables-ipv6
-iptstate
-irda-utils
-irqbalance
-jwhois
-krb5-workstation
-ksh
-lftp
-libevent
-libgssapi
-libIDL
-libidn
-libnl
-libnotify
-libpcap
-libpng-devel
-libsysfs
-libusb-devel
-libutempter
-libvolume_id
-libwnck
-logrotate
-logwatch
-lsof
-m4
-mailcap
-mailx
-make
-man
-man-pages
-mdadm
-mgetty
-microcode_ctl
-mkbootdisk
-mlocate
-mtools
-mtr
-nano
-NetworkManager
-newt
-nfs-utils
-nfs-utils-lib 
-notification-daemon
-nscd
-nspr
-nss
-nss_db
-nss_ldap
-nss-tools
-ntsysv
-numactl
-ORBit2
-pam_ccreds
-pam_krb5
-pam_passwdqc
-pam_pkcs11
-pam_smb
-pango
-paps
-parted
-patch
-pax
-pciutils
-pcmciautils
-pcsc-lite
-pcsc-lite-libs
-perl-String-CRC32
-pinfo
-pkgconfig
-pm-utils
-policycoreutils
-ppp
-prelink
-procmail
-psacct
-quota
-rdate
-rdist
-readahead
-redhat-menus
-rhpl
-rmt
-rng-utils
-rootfiles
-rp-pppoe
-rsh
-rsync
-selinux-policy
-selinux-policy-targeted
-sendmail
-setserial
-setuptool
-slang
-smartmontools
-specspo 
-startup-notification
-stunnel
-sudo
-symlinks
-syslinux
-sysreport
-system-config-network-tui
-talk
-tcpdump
-tcp_wrappers
-tcsh
-telnet
-time
-tmpwatch
-traceroute
-tree
-unix2dos
-unzip
-usbutils
-usermode
-vconfig
-vixie-cron
-wget
-which
-wireless-tools
-words
-wpa_supplicant
-xinetd
-zip
-zlib-devel
%end

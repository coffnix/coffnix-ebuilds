coffnix-ebuilds
================

1- Get this overlay:

~~~~

# mkdir -p /var/overlay/ ; cd /var/overlay/ ; git clone https://github.com/coffnix/coffnix-ebuilds.git

~~~~


2- Configure /etc/make.conf:

~~~~

echo 'PORTDIR_OVERLAY="/var/overlay/local/coffnix-ebuilds"' >> /etc/make.conf

~~~~


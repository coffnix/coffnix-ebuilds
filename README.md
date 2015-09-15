coffnix-ebuilds
================

1- RTFM

http://www.funtoo.org/Local_Overlay

2- Get this overlay:

~~~~
# mkdir -p /var/overlay ; cd /var/overlay
# git clone https://github.com/coffnix/coffnix-ebuilds.git
~~~~


3- Configure /etc/make.conf:

~~~~
# echo 'PORTDIR_OVERLAY="/var/overlay/coffnix-ebuilds/local"' >> /etc/make.conf
~~~~

4- Update your database:

~~~
# emerge app-portage/eix
# eix-update
~~~


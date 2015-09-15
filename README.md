coffnix-ebuilds
================

1- RTFM

http://www.funtoo.org/Local_Overlay

2- Get this overlay:

~~~~
# mkdir -p /var/overlay/local ; cd /var/overlay/local
# git clone https://github.com/coffnix/coffnix-ebuilds.git
~~~~


3- Configure /etc/make.conf:

~~~~
echo 'PORTDIR_OVERLAY="/var/overlay/local/coffnix-ebuilds"' >> /etc/make.conf
~~~~

4- Update your database:

~~~
# emerge app-portage/eix
# eix-update
~~~


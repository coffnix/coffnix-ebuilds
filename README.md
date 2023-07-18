coffnix-ebuilds
================

1- RTFM

http://www.funtoo.org/Local_Overlay

2- Get this overlay:

~~~~
# mkdir -p /var/overlay ; cd /var/overlay
# git clone https://github.com/coffnix/coffnix-ebuilds.git
# mv /var/overlay/coffnix-ebuilds /var/overlay/overlay-local
~~~~


3- Configure /etc/portage/repos.conf/overlay-local.conf::

~~~~
# echo -e "[overlay-local]\nlocation = /var/overlay/overlay-local\nauto-sync = no\npriority = 10" > /etc/portage/repos.conf/overlay-local.conf
~~~~

4- Update your database:

~~~
# emerge app-portage/eix
# eix-update
~~~


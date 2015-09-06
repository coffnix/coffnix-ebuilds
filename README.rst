coffnix-ebuilds
================

1- Get this overlay:

<code># mkdir -p /var/overlay/ ; cd /var/overlay/ ; git clone https://github.com/coffnix/coffnix-ebuilds.git</code>


2- Configure /etc/make.conf:

<code> echo 'PORTDIR_OVERLAY="/var/overlay/local/coffnix-ebuilds"' >> /etc/make.conf</code>



=================================
How to Contribute to this Overlay
=================================

:author: Daniel Robbins
:contact: drobbins@funtoo.org
:language: English

Greetings GitHub Users!
=======================

.. _bugs.funtoo.org: https://bugs.funtoo.org

To contribute bug reports for this overlay, you can open up a GitHub issue or send
me a pull request.

If you are using ebuilds in this overlay as part of Funtoo Linux (because they are
merged into the main Funtoo Linux Portage tree, for example,) then
please also open an issue at `bugs.funtoo.org`_.

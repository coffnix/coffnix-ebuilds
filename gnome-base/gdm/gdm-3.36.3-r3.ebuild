# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"
GNOME3_EAUTORECONF="yes"

inherit eutils gnome3 ltprune pam readme.gentoo-r1 udev user

DESCRIPTION="GNOME Display Manager for managing graphical display servers and user logins"
HOMEPAGE="https://wiki.gnome.org/Projects/GDM"

SRC_URI="${SRC_URI}
	branding? ( https://www.mail-archive.com/tango-artists@lists.freedesktop.org/msg00043/tango-gentoo-v1.1.tar.gz )
"

LICENSE="
	GPL-2+
	branding? ( CC-BY-SA-4.0 )
"

SLOT="0"

IUSE="accessibility audit bluetooth-sound branding fprint +introspection ipv6 plymouth selinux smartcard tcpd test wayland xinerama"
RESTRICT="!test? ( test )"

KEYWORDS="*"

COMMON_DEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.70.0-r1:2=
	dev-libs/libgudev
	>=x11-libs/gtk+-2.91.1:3
	>=gnome-base/dconf-0.20
	>=gnome-base/gnome-settings-daemon-3.1.4
	gnome-base/gsettings-desktop-schemas
	>=media-libs/fontconfig-2.5.0:1.0
	>=media-libs/libcanberra-0.4[gtk3]
	sys-apps/dbus
	>=sys-apps/accountsservice-0.6.35

	x11-apps/sessreg
	|| (
    >=x11-base/xorg-server-21.1.16
    >=x11libre-base/xorg-server-21.1.16
    )
	x11-libs/libXi
	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libxcb
	>=x11-misc/xdg-utils-1.0.2-r3

	virtual/pam
	sys-apps/keyutils:=
	>=sys-auth/elogind-239.3[pam]

	sys-auth/pambase

	audit? ( sys-process/audit )
	introspection? ( >=dev-libs/gobject-introspection-0.9.12:= )
	plymouth? ( sys-boot/plymouth )
	selinux? ( sys-libs/libselinux )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	xinerama? ( x11-libs/libXinerama )
"
# XXX: These deps are from session and desktop files in data/ directory
# fprintd is used via dbus by gdm-fingerprint-extension
# gnome-session-3.6 needed to avoid freezing with orca
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gnome-session-3.6
	>=gnome-base/gnome-shell-3.1.90
	x11-apps/xhost
	accessibility? (
		>=app-accessibility/orca-3.10
		gnome-extra/mousetweaks )
	fprint? (
		sys-auth/fprintd
		sys-auth/pam_fprint )
	gnome-base/adrien-gdm-keyboard"

# FL-7755: for adrien-gdm-keyboard

DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/gdbus-codegen
	dev-util/glib-utils
	>=dev-util/intltool-0.40.0
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
	test? ( >=dev-libs/check-0.9.4 )
	app-text/yelp-tools
" # yelp-tools needed for eautoreconf to not lose help docs (m4_ifdeffed YELP_HELP_INIT call and setup)

DOC_CONTENTS="
	To make GDM start at boot with OpenRC, edit /etc/conf.d to have
	DISPLAYMANAGER=\"gdm\" and enable the xdm service:\n
	# rc-update add xdm
	\n
	For passwordless login to unlock your keyring, you need to install
	sys-auth/pambase with USE=gnome-keyring and set an empty password
	on your keyring. Use app-crypt/seahorse for that.\n
	\n
	You may need to install app-crypt/coolkey and sys-auth/pam_pkcs11
	for smartcard support
"

pkg_setup() {
	enewgroup gdm
	enewgroup video # Just in case it hasn't been created yet
	enewuser gdm -1 -1 /var/lib/gdm gdm,video

	# For compatibility with certain versions of nvidia-drivers, etc., need to
	# ensure that gdm user is in the video group
	if ! egetent group video | grep -q gdm; then
		# FIXME XXX: is this at all portable, ldap-safe, etc.?
		# XXX: egetent does not have a 1-argument form, so we can't use it to
		# get the list of gdm's groups
		local g=$(groups gdm)
		elog "Adding user gdm to video group"
		usermod -G video,${g// /,} gdm || die "Adding user gdm to video group failed"
	fi
}

src_prepare() {
	# ssh-agent handling must be done at xinitrc.d, bug #220603
	eapply "${FILESDIR}/${PN}-3.32.0-xinitrc-ssh-agent.patch"

	# Gentoo does not have a fingerprint-auth pam stack
	eapply "${FILESDIR}/${PN}-3.32.0-fingerprint-auth.patch"

	# Support pam_elogind.so in gdm-launch-environment.pam
	eapply "${FILESDIR}/${PN}-3.32.0-enable-elogind.patch"

	# Show logo when branding is enabled
	use branding && eapply "${FILESDIR}/${PN}-3.32.0-logo.patch"
	eapply "${FILESDIR}/${PN}-3.34.0-support-elogind.patch"
	eapply "${FILESDIR}/${PN}-3.30.2-prioritize-xorg.patch"
	eautoreconf
	gnome3_src_prepare
}

src_configure() {
	local myconf=(
		--enable-gdm-xsession
		--enable-user-display-server
		--with-run-dir=/run/gdm
		--localstatedir="${EPREFIX}"/var
		--disable-static
		--with-xdmcp=yes
		--enable-authentication-scheme=pam
		--with-default-pam-config=exherbo
		--with-pam-mod-dir=$(getpam_mod_dir)
		--with-udevdir=$(get_udevdir)
		--with-at-spi-registryd-directory="${EPREFIX}"/usr/libexec
		--without-xevie
		--disable-systemd-journal
		$(use_with audit libaudit)
		$(use_enable ipv6)
		$(use_with plymouth)
		$(use_with selinux)
		$(use_with tcpd tcp-wrappers)
		$(use_enable wayland wayland-support)
		$(use_with xinerama)
	)

	myconf+=(
		--with-initial-vt=7 # TODO: Revisit together with startDM.sh and other xinit talks; also ignores plymouth possibility
		SYSTEMD_CFLAGS="`pkg-config --cflags "libelogind" 2>/dev/null`"
		SYSTEMD_LIBS="`pkg-config --libs "libelogind" 2>/dev/null`"
	)
	gnome3_src_configure "${myconf[@]}"
}

src_install() {
	gnome3_src_install
	rm -rf ${D}/run ${D}/var/cache

	if ! use accessibility ; then
		rm "${ED}"/usr/share/gdm/greeter/autostart/orca-autostart.desktop || die
	fi

	exeinto /etc/X11/xinit/xinitrc.d
	newexe "${FILESDIR}/49-keychain-r1" 49-keychain
	newexe "${FILESDIR}/50-ssh-agent-r1" 50-ssh-agent

	# gdm user's home directory
	keepdir /var/lib/gdm
	fowners gdm:gdm /var/lib/gdm

	# prevent gdm from also starting pulseaudio, and grabbing audio devices.
	insinto /var/lib/gdm/.pulse
	doins $FILESDIR/client.conf

	# install XDG_DATA_DIRS gdm changes
	echo 'XDG_DATA_DIRS="/usr/share/gdm"' > 99xdg-gdm
	doenvd 99xdg-gdm

	use branding && newicon "${WORKDIR}/tango-gentoo-v1.1/scalable/gentoo.svg" gentoo-gdm.svg
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome3_pkg_postinst
	local d ret

	# bug #669146; gdm may crash if /var/lib/gdm subdirs are not owned by gdm:gdm
	ret=0
	ebegin "Fixing "${EROOT}"/var/lib/gdm ownership"
	chown --no-dereference gdm:gdm "${EROOT}/var/lib/gdm" || ret=1
	for d in "${EROOT}/var/lib/gdm/"{.cache,.color,.config,.pulse,.dbus,.local}; do
		[[ ! -e "${d}" ]] || chown --no-dereference -R gdm:gdm "${d}" || ret=1
	done
	eend ${ret}

	readme.gentoo_print_elog
}

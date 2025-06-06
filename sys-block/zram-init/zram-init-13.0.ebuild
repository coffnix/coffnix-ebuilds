# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit prefix readme.gentoo-r1

DESCRIPTION="Scripts to support compressed swap devices or ramdisks with zRAM"
HOMEPAGE="https://github.com/vaeth/zram-init/"

SRC_URI="https://api.github.com/repos/vaeth/zram-init/tarball/v13.0 -> zram-init-13.0.tar.gz"
KEYWORDS="*"

LICENSE="GPL-2"
SLOT="0"

BDEPEND="sys-devel/gettext"

RDEPEND="
	app-shells/push
	virtual/libintl
	|| ( sys-apps/openrc sys-apps/systemd )
"

DISABLE_AUTOFORMATTING=true
DOC_CONTENTS="\
To use zram-init, activate it in your kernel and add it to the default
runlevel: rc-update add zram-init default
If you use systemd enable zram_swap, zram_tmp, and/or zram_var_tmp with
systemctl. You might need to modify the following file depending on the number
of devices that you want to create: /etc/modprobe.d/zram.conf.
If you use the \$TMPDIR as zram device with OpenRC, you should add zram-init to
the boot runlevel: rc-update add zram-init boot
Still for the same case, you should add in the OpenRC configuration file for
the services using \$TMPDIR the following line: rc_need=\"zram-init\""

src_unpack() {
	default
	rm -rf ${S}
	mv ${WORKDIR}/vaeth-zram-init-* ${S} || die
}

src_prepare() {
	default

	hprefixify "${S}/man/${PN}.8"

	hprefixify -e "s%(}|:)(/(usr/)?sbin)%\1${EPREFIX}\2%g" \
		"${S}/sbin/${PN}.in"

	hprefixify -e "s%( |=)(/tmp)%\1${EPREFIX}\2%g" \
		"${S}/systemd/system"/* \
		"${S}/openrc"/*/*
}

src_compile() {
	emake PREFIX="${EPREFIX}/usr" MODIFY_SHEBANG=FALSE
}

src_install() {
	einstalldocs
	readme.gentoo_create_doc

	emake DESTDIR="${ED}" PREFIX="/usr" SYSCONFDIR="/etc" \
		BINDIR="${ED}/sbin" SYSTEMDDIR="${ED}/lib/systemd/system" install
}

pkg_postinst() {
	readme.gentoo_print_elog
}
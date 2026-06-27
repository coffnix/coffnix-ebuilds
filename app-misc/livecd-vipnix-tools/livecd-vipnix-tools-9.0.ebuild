# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info

DESCRIPTION="Vipnix LiveCD tools for autoconfiguration of hardware"
HOMEPAGE="https://vipnix.com.br"

SRC_URI=""
KEYWORDS="*"

SLOT="0"
LICENSE="GPL-2"

RDEPEND="
	dev-util/dialog
	media-sound/alsa-utils
	net-dialup/mingetty
	sys-apps/openrc
	sys-apps/pciutils
"

S="${WORKDIR}"

pkg_setup() {
	ewarn "This package is designed for use on the LiveCD only and will do"
	ewarn "unspeakably horrible and unexpected things on a normal system."
	ewarn "YOU HAVE BEEN WARNED!!!"

	CONFIG_CHECK="~SND_PROC_FS"
	linux-info_pkg_setup
}

src_install() {
	doconfd "${FILESDIR}"/conf.d/*
	doinitd "${FILESDIR}"/init.d/*
	dosbin "${FILESDIR}"/net-setup
	into /
	dosbin "${FILESDIR}"/livecd-functions.sh
}

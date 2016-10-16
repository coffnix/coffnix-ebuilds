# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils fdo-mime multilib versionator

DESCRIPTION="Watch torrent movies instantly"
HOMEPAGE="https://popcorntime.io/"
MY_PV=$(replace_version_separator 3 '-')

SRC_URI="x86?   ( http://get.popcorntime.io/build/Popcorn-Time-${MY_PV}-Linux-32.tar.xz )
		 amd64? ( http://get.popcorntime.io/build/Popcorn-Time-${MY_PV}-Linux-64.tar.xz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="splitdebug strip"

DEPEND=""
RDEPEND="dev-libs/nss
	gnome-base/gconf
	media-fonts/corefonts
	media-libs/alsa-lib
	x11-libs/gtk+:2
	net-libs/nodejs"

S="${WORKDIR}"

src_install() {
	exeinto /opt/${PN}
	doexe Popcorn-Time
	
	insinto /opt/${PN}
	doins -r src node_modules icudtl.dat locales LICENSE.txt libffmpegsumo.so nw.pak install package.json

	dosym /$(get_libdir)/libudev.so.1 /opt/${PN}/libudev.so.0
	dosym /opt/${PN}/Popcorn-Time /usr/bin/${PN}

	insinto /usr/share/applications
	doins "${FILESDIR}"/${PN}.desktop

	insinto /usr/share/pixmaps
	doins popcorntime.png
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}

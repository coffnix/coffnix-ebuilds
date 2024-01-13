# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake xdg-utils

DESCRIPTION="Qt Image Viewer"
HOMEPAGE="https://lxqt.github.io/"

SRC_URI="https://github.com/lxqt/lximage-qt/releases/download/1.4.0/lximage-qt-1.4.0.tar.xz -> lximage-qt-1.4.0.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2 GPL-2+"
SLOT="0"

BDEPEND="
	dev-qt/linguist-tools:5
	dev-util/lxqt-build-tools
	virtual/pkgconfig
"
DEPEND="
	dev-libs/glib:2
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	media-libs/libexif
	=x11-libs/libfm-qt-${PV}
	x11-libs/libX11
	x11-libs/libXfixes
"
RDEPEND="${DEPEND}"

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}


post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake xdg-utils

DESCRIPTION="Qt GUI Openbox Configuration Tool"
HOMEPAGE="https://lxqt.github.io/"

SRC_URI="https://github.com/lxqt/obconf-qt/releases/download/0.16.3/obconf-qt-0.16.3.tar.xz -> obconf-qt-0.16.3.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2 GPL-2+"
SLOT="0"

BDEPEND="
	dev-qt/linguist-tools:5
	dev-util/lxqt-build-tools
	sys-apps/sed
	virtual/pkgconfig
"
DEPEND="
	dev-libs/glib:2
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	x11-libs/libX11
	x11-wm/openbox:3
"
RDEPEND="${DEPEND}
	!lxqt-base/lxqt-l10n
"

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}
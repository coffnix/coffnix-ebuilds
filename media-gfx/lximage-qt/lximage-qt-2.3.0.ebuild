# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="$(ver_cut 1-2)"

inherit cmake xdg

DESCRIPTION="Qt Image Viewer"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2+"
SLOT="0"

BDEPEND="
	>=dev-qt/qttools-6.6:6[linguist]
	>=dev-util/lxqt-build-tools-2.3.0
	virtual/pkgconfig
"
DEPEND="
	dev-libs/glib:2
	>=dev-qt/qtbase-6.6:6[dbus,gui,network,widgets]
	>=dev-qt/qtsvg-6.6:6
	media-libs/libexif
	=x11-libs/libfm-qt-${MY_PV}*:=
	x11-libs/libX11
	x11-libs/libXfixes
"
RDEPEND="${DEPEND}"

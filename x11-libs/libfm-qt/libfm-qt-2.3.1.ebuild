# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="$(ver_cut 1-2)"

inherit cmake xdg

DESCRIPTION="Qt Library for Building File Managers"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="BSD GPL-2+ LGPL-2.1+"
SLOT="0/17"

BDEPEND="
	>=dev-qt/qttools-6.6:6[linguist]
	>=dev-util/lxqt-build-tools-2.3.0
	virtual/pkgconfig
"
DEPEND="
	dev-libs/glib:2
	>=dev-qt/qtbase-6.6:6=[gui,widgets,X]
	>=lxde-base/menu-cache-1.1.0:=
	=lxqt-base/lxqt-menu-data-${MY_PV}*
	media-libs/libexif
	x11-libs/libxcb:=
"
RDEPEND="${DEPEND}"

src_prepare() {
	cmake_src_prepare
}

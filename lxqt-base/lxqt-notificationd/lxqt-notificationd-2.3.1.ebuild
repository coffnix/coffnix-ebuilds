# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="LXQt notification daemon and library"
HOMEPAGE="https://lxqt-project.org/"

MY_PV="$(ver_cut 1-2)"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1 LGPL-2.1+"
SLOT="0"

BDEPEND="
	>=dev-qt/qttools-6.6:6[linguist]
	>=dev-util/lxqt-build-tools-2.3.0
"
DEPEND="
	>=dev-libs/libqtxdg-4.3.0
	>=dev-qt/qtbase-6.6:6[dbus,gui,widgets]
	kde-frameworks/kwindowsystem:6
	>=kde-plasma/layer-shell-qt-6.0:6
	=lxqt-base/liblxqt-${MY_PV}*:=
"
RDEPEND="${DEPEND}"

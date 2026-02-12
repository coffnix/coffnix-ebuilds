# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="$(ver_cut 1-2)"

inherit cmake xdg

DESCRIPTION="LXQt system configuration control center"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2 GPL-2+ GPL-3 LGPL-2 LGPL-2+ LGPL-2.1+ WTFPL-2"
SLOT="0"
IUSE="+monitor +touchpad"

BDEPEND="
	>=dev-qt/qttools-6.6:6[linguist]
	>=dev-util/lxqt-build-tools-2.3.0
"
DEPEND="
	>=dev-libs/libqtxdg-4.3.0
	>=dev-qt/qtbase-6.6:6[gui,widgets,xml]
	>=dev-qt/qtsvg-6.6:6
	=lxqt-base/liblxqt-${MY_PV}*:=
	=lxqt-base/lxqt-menu-data-${MY_PV}*
	virtual/zlib:=
	x11-apps/setxkbmap
	x11-libs/libxcb:=
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXfixes
	monitor? ( kde-plasma/libkscreen:6= )
	touchpad? (
		virtual/libudev:=
		x11-libs/libXi
		|| (
			x11-drivers/xf86-input-libinput
			xlibre-drivers/xf86-input-libinput
		)
	)
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DWITH_MONITOR=$(usex monitor)
		-DWITH_TOUCHPAD=$(usex touchpad)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install
	doman man/*.1 liblxqt-config-cursor/man/*.1 lxqt-config-appearance/man/*.1
}

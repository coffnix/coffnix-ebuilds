# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="$(ver_cut 1-2)"

inherit cmake xdg-utils

DESCRIPTION="LXQt system configuration control center"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2 GPL-2+ GPL-3 LGPL-2 LGPL-2+ LGPL-2.1+ WTFPL-2"
SLOT="0"
IUSE="+monitor +touchpad"

BDEPEND="
	>=dev-qt/linguist-tools-5.15:5
"
DEPEND="
	>=dev-libs/libqtxdg-3.11.0
	>=dev-qt/qtcore-5.15:5
	>=dev-qt/qtgui-5.15:5
	>=dev-qt/qtwidgets-5.15:5
	>=dev-qt/qtsvg-5.15:5
	>=dev-qt/qtx11extras-5.15:5
	>=dev-qt/qtxml-5.15:5
	=lxqt-base/liblxqt-${MY_PV}*:=
	=lxqt-base/lxqt-menu-data-${MY_PV}*
	sys-libs/zlib:=
	x11-apps/setxkbmap
	x11-libs/libxcb:=
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXfixes
	monitor? ( kde-plasma/libkscreen:5= )
	touchpad? (
		virtual/libudev:=
		x11libre-drivers/xf86-input-libinput
		x11-libs/libXi
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

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}

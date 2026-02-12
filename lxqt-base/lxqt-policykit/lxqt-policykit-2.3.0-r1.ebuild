# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="LXQt PolKit authentication agent"
HOMEPAGE="https://lxqt-project.org/"

MY_PV="$(ver_cut 1-2)"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1 LGPL-2.1+"
SLOT="0"

BDEPEND="
	>=dev-qt/qttools-6.6:6[linguist]
	>=dev-util/lxqt-build-tools-2.3.0
	virtual/pkgconfig
"
DEPEND="
	>=dev-qt/qtbase-6.6:6[gui,widgets]
	=lxqt-base/liblxqt-${MY_PV}*:=
	>=sys-auth/polkit-qt-0.200.0[qt6(+)]
"
RDEPEND="${DEPEND}"

src_install() {
	cmake_src_install
	doman man/*.1
}

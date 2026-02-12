# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Daemon and library for global keyboard shortcuts registration"
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
	>=dev-qt/qtbase-6.6:6[dbus,gui,widgets]
	=lxqt-base/liblxqt-${MY_PV}*:=
	x11-libs/libX11
"
RDEPEND="${DEPEND}"

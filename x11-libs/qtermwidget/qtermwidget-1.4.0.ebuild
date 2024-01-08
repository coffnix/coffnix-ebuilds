# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Qt terminal emulator widget"
KEYWORDS="*"
HOMEPAGE="https://lxqt-project.org/"


LICENSE="BSD GPL-2 LGPL-2+"
SLOT="0/${PV}"

BDEPEND="
	>=dev-qt/linguist-tools-5.15:5
	>=dev-util/lxqt-build-tools-0.13.0
"
DEPEND="
	>=dev-qt/qtcore-5.15:5
	>=dev-qt/qtgui-5.15:5
	>=dev-qt/qtwidgets-5.15:5
"
RDEPEND="${DEPEND}"

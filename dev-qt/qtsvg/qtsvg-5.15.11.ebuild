# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *9999* ]]; then
	QT5_KDEPATCHSET_REV=1
	KEYWORDS="amd64 arm arm64 ~hppa ~loong ppc ppc64 ~riscv ~sparc x86"
fi

inherit qt5-build

DESCRIPTION="SVG rendering library for the Qt5 framework"

IUSE=""

RDEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtgui-5.15.11*
	=dev-qt/qtwidgets-5.15.11*
	sys-libs/zlib:=
"
DEPEND="${RDEPEND}
	test? ( =dev-qt/qtxml-5.15.11* )
"

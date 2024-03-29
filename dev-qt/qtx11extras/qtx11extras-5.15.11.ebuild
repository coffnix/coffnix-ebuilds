# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qt5-build

DESCRIPTION="Linux/X11-specific support library for the Qt5 framework"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="amd64 arm arm64 ~hppa ~loong ppc ppc64 ~riscv ~sparc x86"
fi

IUSE=""

RDEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtgui-5.15.11*[X]
"
DEPEND="${RDEPEND}
	test? ( =dev-qt/qtwidgets-5.15.11* )
"

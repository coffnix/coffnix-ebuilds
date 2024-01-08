# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *9999* ]]; then
	QT5_KDEPATCHSET_REV=1
	KEYWORDS="amd64 ~arm arm64 ~loong ~ppc64 ~riscv x86"
fi

inherit qt5-build

DESCRIPTION="Set of next generation Qt Quick controls for the Qt5 framework"

IUSE="widgets"

DEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtdeclarative-5.15.11*
	=dev-qt/qtgui-5.15.11*
	widgets? ( =dev-qt/qtwidgets-5.15.11* )
"
RDEPEND="${DEPEND}
	=dev-qt/qtgraphicaleffects-5.15.11*
"

src_prepare() {
	qt_use_disable_mod widgets widgets \
		src/imports/platform/platform.pro

	qt5-build_src_prepare
}

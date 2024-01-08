# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qt5-build

DESCRIPTION="Chart component library for the Qt5 framework"
LICENSE="GPL-3"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="amd64 ~arm arm64 ~loong ppc ppc64 ~riscv x86"
fi

IUSE="qml"

DEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtgui-5.15.11*
	=dev-qt/qtwidgets-5.15.11*
	qml? ( =dev-qt/qtdeclarative-5.15.11* )
"
RDEPEND="${DEPEND}"

src_prepare() {
	qt_use_disable_mod qml quick \
		src/src.pro

	qt5-build_src_prepare
}

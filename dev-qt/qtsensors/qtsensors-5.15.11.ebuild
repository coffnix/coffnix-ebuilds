# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qt5-build

DESCRIPTION="Hardware sensor access library for the Qt5 framework"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="amd64 arm arm64 ~hppa ~loong ~ppc ppc64 ~riscv ~sparc x86"
fi

# TODO: simulator
IUSE="qml"

RDEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtdbus-5.15.11*
	qml? ( =dev-qt/qtdeclarative-5.15.11* )
"
DEPEND="${RDEPEND}"

src_prepare() {
	qt_use_disable_mod qml quick \
		src/src.pro

	qt5-build_src_prepare
}

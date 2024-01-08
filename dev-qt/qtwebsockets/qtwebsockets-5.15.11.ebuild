# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *9999* ]]; then
	QT5_KDEPATCHSET_REV=1
	KEYWORDS="amd64 arm arm64 ~hppa ~loong ~ppc ppc64 ~riscv ~sparc x86"
fi

inherit qt5-build

DESCRIPTION="Implementation of the WebSocket protocol for the Qt5 framework"

IUSE="qml +ssl"

DEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtnetwork-5.15.11*[ssl=]
	qml? ( =dev-qt/qtdeclarative-5.15.11* )

"
RDEPEND="${DEPEND}"

src_prepare() {
	qt_use_disable_mod qml quick src/src.pro

	qt5-build_src_prepare
}

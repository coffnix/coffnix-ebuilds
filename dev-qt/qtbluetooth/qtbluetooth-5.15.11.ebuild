# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *9999* ]]; then
	QT5_KDEPATCHSET_REV=1
	KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
fi

QT5_MODULE="qtconnectivity"
inherit qt5-build

DESCRIPTION="Bluetooth support library for the Qt5 framework"

IUSE="qml"

DEPEND="
	=dev-qt/qtconcurrent-5.15.11*
	=dev-qt/qtcore-5.15.11*:5=
	=dev-qt/qtdbus-5.15.11*
	=dev-qt/qtnetwork-5.15.11*
	>=net-wireless/bluez-5:=
	qml? ( =dev-qt/qtdeclarative-5.15.11* )
"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i -e 's/nfc//' src/src.pro || die

	qt_use_disable_mod qml quick src/src.pro

	qt5-build_src_prepare
}

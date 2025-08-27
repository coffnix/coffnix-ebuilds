# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Bluetooth support library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtconnectivity-everywhere-opensource-src-5.15.16.tar.xz -> qtbluetooth-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="qml"
RDEPEND="dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	net-wireless/bluez
	qml? ( dev-qt/qtdeclarative:5 )
	
"
DEPEND="${RDEPEND}
	dev-qt/qtnetwork:5
	
"
S="${WORKDIR}/qtconnectivity-everywhere-src-5.15.16"
src_prepare() {
	sed -i -e 's/nfc//' src/src.pro || die
	qt_use_disable_mod qml quick src/src.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild

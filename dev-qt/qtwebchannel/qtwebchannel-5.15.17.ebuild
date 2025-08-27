# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Qt5 module for integrating C++ and QML applications with HTML/JavaScript clients"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtwebchannel-everywhere-opensource-src-5.15.17.tar.xz -> qtwebchannel-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="qml"
RDEPEND="dev-qt/qtcore:5
	qml? ( dev-qt/qtdeclarative:5 )
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	qt_use_disable_mod qml quick src/src.pro
	qt_use_disable_mod qml qml src/webchannel/webchannel.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild

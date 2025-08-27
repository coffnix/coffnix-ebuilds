# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Hardware sensor access library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtsensors-everywhere-opensource-src-5.15.16.tar.xz -> qtsensors-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="qml"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdbus:5
	qml? ( dev-qt/qtdeclarative:5 )
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	qt_use_disable_mod qml quick \
	  src/src.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild

# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Chart component library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtcharts-everywhere-opensource-src-5.15.17.tar.xz -> qtcharts-everywhere-opensource-src-5.15.17.tar.xz"
LICENSE="GPL-3"
SLOT="5"
KEYWORDS="*"
IUSE="qml vulkan"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5[vulkan=]
	dev-qt/qtwidgets:5
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

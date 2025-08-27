# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Set of next generation Qt Quick controls for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtquickcontrols2-everywhere-opensource-src-5.15.17.tar.xz -> qtquickcontrols2-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="widgets"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	widgets? ( dev-qt/qtwidgets:5 )
	
"
DEPEND="${RDEPEND}
	dev-qt/qtgraphicaleffects:5
	
"
src_prepare() {
	qt_use_disable_mod widgets widgets \
	  src/imports/platform/platform.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild

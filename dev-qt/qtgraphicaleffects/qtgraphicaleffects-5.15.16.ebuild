# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Set of QML types for adding visual effects to user interfaces"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtgraphicaleffects-everywhere-opensource-src-5.15.16.tar.xz -> qtgraphicaleffects-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtdeclarative:5
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

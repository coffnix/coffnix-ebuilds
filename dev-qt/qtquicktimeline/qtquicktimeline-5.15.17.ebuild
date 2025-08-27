# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Qt module for keyframe-based timeline construction"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtquicktimeline-everywhere-opensource-src-5.15.17.tar.xz -> qtquicktimeline-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

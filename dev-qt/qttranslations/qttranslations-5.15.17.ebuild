# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Translation files for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qttranslations-everywhere-opensource-src-5.15.17.tar.xz -> qttranslations-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
BDEPEND="dev-qt/linguist-tools:5
	
"
DEPEND="dev-qt/qtcore:5
	
"

# vim: filetype=ebuild

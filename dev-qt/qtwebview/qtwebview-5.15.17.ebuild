# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Module for displaying web content in a QML application using the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtwebview-everywhere-opensource-src-5.15.17.tar.xz -> qtwebview-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtwebengine:5
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

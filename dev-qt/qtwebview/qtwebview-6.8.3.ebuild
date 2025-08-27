# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Module for displaying web content in a QML application using the Qt framework"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtwebview-everywhere-src-6.8.3.tar.xz -> qtwebview-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtwebengine:6
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

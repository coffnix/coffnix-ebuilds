# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Location (places, maps, navigation) library for the Qt framework"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtlocation-everywhere-src-6.8.3.tar.xz -> qtlocation-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtpositioning:6
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

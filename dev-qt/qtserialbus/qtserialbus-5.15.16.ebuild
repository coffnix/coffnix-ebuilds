# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Qt module to access CAN, ModBus, and other industrial serial buses and protocols"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtserialbus-everywhere-opensource-src-5.15.16.tar.xz -> qtserialbus-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtnetwork:5
	dev-qt/qtserialport:5
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

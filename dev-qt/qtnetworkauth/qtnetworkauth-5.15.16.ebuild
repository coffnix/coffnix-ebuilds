# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Network authorization library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtnetworkauth-everywhere-opensource-src-5.15.16.tar.xz -> qtnetworkauth-everywhere-opensource-src-5.15.16.tar.xz"
LICENSE="GPL-3"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtnetwork:5
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

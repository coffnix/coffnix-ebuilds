# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Network authorization library for the Qt framework"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtnetworkauth-everywhere-src-6.8.3.tar.xz -> qtnetworkauth-everywhere-src-6.8.3.tar.xz"
LICENSE="GPL-3"
SLOT="6"
KEYWORDS="*"
RDEPEND="dev-qt/qtbase:6
	
"
DEPEND="${RDEPEND}
"

# vim: filetype=ebuild

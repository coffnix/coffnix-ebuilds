# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Module provides a set of easy-to-use chart components"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtcharts-everywhere-src-6.8.3.tar.xz -> qtcharts-everywhere-src-6.8.3.tar.xz"
LICENSE="GPL-3"
SLOT="6"
KEYWORDS="*"
IUSE="qml"
# Commons depends
CDEPEND="dev-qt/qtbase:6[gui]
	qml? ( dev-qt/qtdeclarative:6 )
	
"
RDEPEND="${CDEPEND}
"
DEPEND="${CDEPEND}
"
src_configure() {
	local mycmakeargs=(
	  $(cmake_use_find_package qml Qt6Qml)
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild

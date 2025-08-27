# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Qt Graphical Effects module from Qt 5 provided for compatibility"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qt5compat-everywhere-src-6.8.3.tar.xz -> qt5compat-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="qml"
# Commons depends
CDEPEND="dev-libs/icu:=
	dev-qt/qtbase:6[gui]
	qml? (
	  dev-qt/qtdeclarative:6
	  dev-qt/qtshadertools:6
	)
	
"
RDEPEND="${CDEPEND}
"
DEPEND="${CDEPEND}
"
src_configure() {
	local mycmakeargs=(
	  $(cmake_use_find_package qml Qt6Quick)
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild

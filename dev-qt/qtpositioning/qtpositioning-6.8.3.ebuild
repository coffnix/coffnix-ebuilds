# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Provides access to position, satellite info and area monitoring classes"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtpositioning-everywhere-src-6.8.3.tar.xz -> qtpositioning-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="geoclue nmea +qml"
# Commons depends
CDEPEND="dev-qt/qtbase:6
	nmea? (
	  dev-qt/qtserialport:6
	)
	qml? ( dev-qt/qtdeclarative:6 )
	
"
RDEPEND="${CDEPEND}
	geoclue? ( app-misc/geoclue:2.0 )
	
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

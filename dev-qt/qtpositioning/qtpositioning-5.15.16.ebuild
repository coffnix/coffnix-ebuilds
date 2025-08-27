# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Physical position determination library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtlocation-everywhere-opensource-src-5.15.16.tar.xz -> qtpositioning-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="geoclue +qml"
RDEPEND="dev-qt/qtcore:5
	geoclue? ( dev-qt/qtdbus:5
	qml? ( dev-qt/qtdeclarative:5 )
	
"
DEPEND="${RDEPEND}
"
PDEPEND="geoclue? ( appmisc/geoclue:2.0 )
	
"
S="${WORKDIR}/qtlocation-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/3rdparty/clipper
	src/3rdparty/poly2tri
	src/3rdparty/clip2tri
	src/positioning
	src/plugins/position/positionpoll
)
pkg_setup() {
	use geoclue && QT5_TARGET_SUBDIRS+=( src/plugins/position/geoclue2 )
	use qml && QT5_TARGET_SUBDIRS+=(
	  src/positioningquick
	  src/imports/positioning
	)
}


# vim: filetype=ebuild

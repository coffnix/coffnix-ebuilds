# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Location (places, maps, navigation) library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtlocation-everywhere-opensource-src-5.15.17.tar.xz -> qtlocation-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
RDEPEND="dev-libs/icu:=
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtpositioning:5[qml]
	dev-qt/qtsql:5
	sys-libs/zlib
	
"
DEPEND="${RDEPEND}
	dev-qt/qtconcurrent:5
	
"
QT5_TARGET_SUBDIRS=(
	src/3rdparty/clipper
	src/3rdparty/poly2tri
	src/3rdparty/clip2tri
	src/3rdparty/mapbox-gl-native
	src/location
	src/imports/location
	src/imports/locationlabs
	src/plugins/geoservices
)
src_prepare() {
	qt5-build_src_prepare
}
src_configure() {
	# src/plugins/geoservices requires files that are only generated when
	# qmake is run in the root directory. Bug 633776.
	mkdir -p "${QT5_BUILD_DIR}"/src/location || die
	qt5_qmake "${QT5_BUILD_DIR}"
	cp "${S}"/src/location/qtlocation-config.pri "${QT5_BUILD_DIR}"/src/location || die
	qt5-build_src_configure
}


# vim: filetype=ebuild

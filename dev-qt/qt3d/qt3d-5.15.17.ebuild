# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="3D rendering module for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qt3d-everywhere-opensource-src-5.15.17.tar.xz -> qt3d-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="gamepad gles2-only qml vulkan"
RDEPEND="dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5[vulkan=]
	dev-qt/qtnetwork:5
	media-libs/assimp
	gamepad? ( dev-qt/qtgamepad:5 )
	qml? ( dev-qt/qtdeclarative:5[gles2-only=] )
	
"
DEPEND="${RDEPEND}
	vulkan? ( dev-util/vulkan-headers )
	
"
src_configure() {
	local myqmakeargs=(
	  --
	  -system-assimp
	)
	qt5-build_src_configure
}
src_prepare() {
	rm -r src/3rdparty/assimp/src/{code,contrib,include} || die
	qt_use_disable_mod gamepad gamepad src/input/frontend/frontend.pri
	qt_use_disable_mod qml quick src/src.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild

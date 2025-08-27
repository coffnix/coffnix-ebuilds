# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Provides a high-level API for creating 3D content or UIs based on Qt Quick"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtquick3d-everywhere-src-6.8.3.tar.xz -> qtquick3d-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
RDEPEND="dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtquicktimeline:6
	dev-qt/qtshadertools:6
	media-libs/assimp
	sys-libs/zlib
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local mycmakeargs=(
	  -DINPUT_openxr=no
	  -DQT_FEATURE_quick3dxr_openxr=OFF
	  -DQT_FEATURE_system_assimp=ON
	  -DQT_FEATURE_system_openxr=ON
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild

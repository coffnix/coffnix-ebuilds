# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="3D rendering module for the Qt6 framework"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qt3d-everywhere-src-6.8.3.tar.xz -> qt3d-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
# Commons depends
CDEPEND="media-libs/assimp
	dev-qt/qtbase:6[gles2-only,gui,vulkan]
	dev-qt/qtdeclarative:6
	dev-qt/qtmultimedia:6
	dev-qt/qtshadertools:6
	sys-libs/zlib
	
"
RDEPEND="${CDEPEND}
	
"
DEPEND="${CDEPEND}
	
"
src_configure() {
	local mycmakeargs=(
	  -DQT_FEATURE_qt3d_system_assimp=ON
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild

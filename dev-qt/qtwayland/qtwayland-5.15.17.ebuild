# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Wayland platform plugin for Qt"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtwayland-everywhere-opensource-src-5.15.17.tar.xz -> qtwayland-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="vulkan"
RDEPEND="dev-libs/wayland
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	media-libs/libglvnd
	x11-libs/libxkbcommon
	vulkan? ( dev-util/vulkan-headers )
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local myqmakeargs=(
	  --
	  $(qt_use vulkan feature-wayland-vulkan-server-buffer)
	)
	qt5-build_src_configure
}


# vim: filetype=ebuild

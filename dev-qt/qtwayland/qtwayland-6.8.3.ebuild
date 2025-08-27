# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt6-build

DESCRIPTION="Wayland platform plugin for Qt"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtwayland-everywhere-src-6.8.3.tar.xz -> qtwayland-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="qml vulkan"
RDEPEND="dev-libs/wayland
	dev-qt/qtbase:6
	dev-qt/qtsvg:6
	dev-util/wayland-scanner
	media-libs/libglvnd
	x11-libs/libxkbcommon
	qml? ( dev-qt/qtdeclarative:6 )
	vulkan? ( dev-util/vulkan-headers )
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local mycmakeargs=(
	  $(cmake_use_find_package qml Qt6Quick)
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild

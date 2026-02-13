# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake xdg

DESCRIPTION="Framework providing assorted high-level user interface components"
HOMEPAGE="https://invent.kde.org/frameworks/"
SRC_URI="https://download.kde.org/stable/frameworks/6.22/kguiaddons-6.22.0.tar.xz -> kguiaddons-6.22.0.tar.xz"
LICENSE="GPL-2"
SLOT="6"
KEYWORDS="*"
IUSE="dbus wayland X"
BDEPEND="wayland? (
	  dev-util/wayland-scanner
	)
	
"
RDEPEND="virtual/kde-seed[gui,declarative,wayland?,X?]
	X? (
	  x11-libs/libX11
	  x11-libs/libxcb
	)
	
"
DEPEND="${RDEPEND}
	wayland? (
	    dev-libs/wayland
	    >=dev-libs/plasma-wayland-protocols-1.15.0
	    >=dev-libs/wayland-protocols-1.39
	)
	X? (
	  x11-base/xorg-proto
	)
	
"

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
	    -DBUILD_GEO_SCHEME_HANDLER=ON
	    -DUSE_DBUS=$(usex dbus)
	    -DWITH_WAYLAND=$(usex wayland)
	    -DWITH_X11=$(usex X)
	    -DBUILD_PYTHON_BINDINGS=OFF
	    -DCMAKE_DISABLE_FIND_PACKAGE_{Python3,PySide6,Shiboken6}=ON
	)
	cmake_src_configure
}


# vim: filetype=ebuild

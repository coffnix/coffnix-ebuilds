# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit meson python-any-r1

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="https://cairographics.org/cairomm/ https://gitlab.freedesktop.org/cairo/cairomm"
SRC_URI="https://cairographics.org/releases/cairomm-1.14.5.tar.xz -> cairomm-1.14.5.tar.xz"
LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="gtk-doc X"
BDEPEND="virtual/pkgconfig
	gtk-doc? (
	  ${PYTHON_DEPS}
	  dev-cpp/mm-common
	  app-text/doxygen[dot]
	  dev-libs/libxslt
	)
	
"
RDEPEND="dev-libs/libsigc++:3
	x11-libs/cairo
	
"
DEPEND="${RDEPEND}
"
pkg_setup() {
	use gtk-doc && python-any-r1_pkg_setup
}
src_configure() {
	local emesonargs=(
	  -Dbuild-documentation=$(usex gtk-doc true false)
	  -Dbuild-examples=false
	  -Dbuild-tests=false
	  -Dboost-shared=true
	)
	meson_src_configure
}


# vim: filetype=ebuild

# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit gnome.org meson python-any-r1

DESCRIPTION="C++ interface for pango"
HOMEPAGE="https://www.gtkmm.org https://gitlab.gnome.org/GNOME/pangomm"

LICENSE="LGPL-2.1+"
SLOT="1.4"
KEYWORDS=""
IUSE="+gtk-doc doc"

RDEPEND="
	>=dev-cpp/cairomm-1.2.2:0[doc?]
	>=dev-cpp/glibmm-2.48.0:2[doc?]
	dev-libs/libsigc++:2[doc?]
	>=x11-libs/pango-1.45.1
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	gtk-doc? (
		>=dev-cpp/mm-common-1.0.4
		app-doc/doxygen
		dev-libs/libxslt
	)
	${PYTHON_DEPS}
"

src_configure() {
	local emesonargs=(
		-Dmaintainer-mode=false
		$(meson_native_use_bool gtk-doc build-documentation)
	)
	meson_src_configure
}


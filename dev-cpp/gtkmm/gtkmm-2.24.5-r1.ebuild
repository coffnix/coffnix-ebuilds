# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2

DESCRIPTION="C++ interface for GTK+"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="2.4"
KEYWORDS="*"
IUSE="doc examples test"

RDEPEND="
	dev-cpp/glibmm:2
	>=x11-libs/gtk+-2.24.15:2
	>=x11-libs/gdk-pixbuf-2.39.2:2
	>=dev-cpp/atkmm-2.22.7:0
	dev-cpp/cairomm:0
	dev-cpp/pangomm:1.4
	>=dev-libs/libsigc++-2.3.2:2
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-doc/doxygen )
"

src_prepare() {
	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed 1 failed"
	fi

	if ! use examples; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)demos\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed 2 failed"
	fi

	gnome2_src_prepare
}

src_configure() {
	ECONF_SOURCE="${S}" \
	gnome2_src_configure \
		--enable-api-atkmm \
		$(native_use_enable doc documentation)
}

src_install() {
	gnome2_src_install

	DOCS="AUTHORS ChangeLog PORTING NEWS README"
	einstalldocs
}

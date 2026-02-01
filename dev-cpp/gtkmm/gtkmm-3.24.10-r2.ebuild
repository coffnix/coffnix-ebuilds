# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome2 virtualx meson

DESCRIPTION="C++ interface for GTK+"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="3.0"
KEYWORDS="*"

IUSE="aqua doc test wayland X"
REQUIRED_USE="|| ( aqua wayland X )"

RDEPEND="
	>=dev-cpp/glibmm-2.62.0
	>=x11-libs/gtk+-3.24.12:3[wayland?,X?]
	>=x11-libs/gdk-pixbuf-2.39.2:2
	>=dev-cpp/atkmm-2.24.2:0
	>=dev-cpp/cairomm-1.12.0:0
	>=dev-cpp/pangomm-2.38.2:1.4
	>=dev-libs/libsigc++-2.3.2:2
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-doc/doxygen )
"
# eautoreconf needs mm-common

src_prepare() {
	if ! use test; then
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am || die "sed 1 failed"
	fi

	sed 's/^\(SUBDIRS =.*\)demos\(.*\)$/\1\2/' -i Makefile.am || die "sed 2 failed"

	gnome2_src_prepare
}

#src_configure() {
#	ECONF_SOURCE="${S}" gnome2_src_configure \
#		--enable-api-atkmm \
#		$(use_enable doc documentation) \
#		$(use_enable aqua quartz-backend) \
#		$(use_enable wayland wayland-backend) \
#		$(use_enable X x11-backend)
#}

multilib_src_configure() {
    local emesonargs=(
        -Dbuild-atkmm-api=true
        -Dbuild-demos=false
        $(meson_native_use_bool gtk-doc build-documentation)
        $(meson_use test build-tests)
        $(meson_use X build-x11-api)
    )
    meson_src_configure
}

src_test() {
	virtx emake check
}

src_install() {
	meson_src_install
	dodoc -r demos
}

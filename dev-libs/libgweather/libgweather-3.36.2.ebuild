# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"

inherit gnome.org gnome3-utils meson vala xdg

DESCRIPTION="Location and timezone database and weather-lookup library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibGWeather"

LICENSE="GPL-2+"
SLOT="2/3-16" # subslot = 3-(libgweather-3 soname suffix)
KEYWORDS="*"

IUSE="glade gtk-doc +vala"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=x11-libs/gtk+-3.24.12:3[introspection]
	>=net-libs/libsoup-2.44:2.4
	>=dev-libs/libxml2-2.6.0:2
	sci-geosciences/geocode-glib
	>=sys-libs/timezone-data-2010k
	glade? ( >=dev-util/glade-3.16:3.10 )
	>=dev-libs/gobject-introspection-1.62.0:=
"
DEPEND="${RDEPEND}
	gtk-doc? ( >=dev-util/gtk-doc-1.11
		app-text/docbook-xml-dtd:4.3 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	xdg_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use glade glade_catalog)
		$(meson_use vala enable_vala)
		$(meson_use gtk-doc gtk_doc)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome3_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome3_schemas_update
}

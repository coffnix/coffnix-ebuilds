# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="GLib geocoding library that uses the Yahoo! Place Finder service"
HOMEPAGE="https://git.gnome.org/browse/geocode-glib"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="+introspection test"

RESTRICT="test"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/json-glib-0.99.2[introspection?]
	gnome-base/gvfs[http]
	>=net-libs/libsoup-2.42:2.4[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.13
	>=sys-devel/gettext-0.18
	virtual/pkgconfig
	test? ( sys-apps/dbus )
"

src_configure() {
	local emesonargs=(
		$(meson_use introspection enable-introspection)
		$(meson_use test enable-installed-tests) \
		-Denable-gtk-doc=true
	)

	meson_src_configure
}

src_compile() {
	export MAKEOPTS="-j1"
	meson_src_compile
}

src_install() {
        export MAKEOPTS="-j1"
        meson_src_install
}

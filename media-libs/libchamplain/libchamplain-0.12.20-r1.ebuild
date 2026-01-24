# Distributed under the terms of the GNU General Public License v2

EAPI=6
VALA_USE_DEPEND="vapigen"

inherit gnome2 meson vala

DESCRIPTION="Clutter based world map renderer"
HOMEPAGE="https://wiki.gnome.org/Projects/libchamplain"

SLOT="0.12"
LICENSE="LGPL-2"
KEYWORDS="*"

IUSE="doc +gtk +introspection +vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	dev-db/sqlite:3
	>=dev-libs/glib-2.62.2:2
	>=media-libs/clutter-1.24:1.0[introspection?]
	media-libs/cogl:=
	>=net-libs/libsoup-2.42:2.4
	>=x11-libs/cairo-1.16.0
	x11-libs/gtk+:3
	gtk? (
		x11-libs/gtk+:3[introspection?]
		media-libs/clutter-gtk:1.0 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc-am )
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	eapply_user

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dmemphis=false
		-Ddemos=false
		$(meson_use introspection)
		$(meson_use doc gtk_doc)
		$(meson_use gtk widgetry)
		$(meson_use vala vapi)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
}

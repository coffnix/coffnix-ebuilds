# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_MIN_API_VERSION="0.56"
VALA_MAX_API_VERSION="0.56"
VALA_USE_DEPEND="vapigen"

inherit gnome3 vala virtualx meson

DESCRIPTION="A text widget implementing syntax highlighting and other features"
HOMEPAGE="https://wiki.gnome.org/Projects/GtkSourceView"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="4"

IUSE="doc glade +introspection test +vala"
REQUIRED_USE="vala? ( introspection )"

KEYWORDS="*"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libxml2-2.6:2
	>=x11-libs/gtk+-3.24.12:3[introspection?]
	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
DEPEND="${RDEPEND}
	dev-util/glib-utils
	>=dev-util/gtk-doc-am-1.25
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use glade glade_catalog)
		$(meson_use introspection gir)
		$(meson_use vala vapi)
		$(meson_use doc gtk_doc)
		$(meson_use test install_tests)
	)

	meson_src_configure
}

src_test() {
	virtx emake check
}

src_install() {
	meson_src_install

	insinto /usr/share/${PN}-4/language-specs
	doins "${FILESDIR}"/2.0/gentoo.lang

	# Avoid conflict with gtksourceview:3.0 glade-catalog
	# TODO: glade doesn't actually show multiple GtkSourceView widget collections, so with both installed, can't really be sure which ones are used
	if use glade; then
		mv "${ED}"/usr/share/glade/catalogs/gtksourceview.xml "${ED}"/usr/share/glade/catalogs/gtksourceview-${SLOT}.xml || die
	fi
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"

inherit gnome3 vala meson

DESCRIPTION="GNOME contact management application"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/Contacts"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="valadocs telepathy v4l"

VALA_DEPEND="
	$(vala_depend)
	>=dev-libs/gobject-introspection-1.62.0:=
	dev-libs/folks[vala(+)]
	gnome-base/gnome-desktop:3=[introspection]
	gnome-extra/evolution-data-server[vala]
	net-libs/telepathy-glib[vala]
"
# Configure is wrong; it needs cheese-3.5.91, not 3.3.91
RDEPEND="
	>=dev-libs/folks-0.9.5:=[eds]
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libgee-0.10:0.8
	>=gnome-extra/evolution-data-server-3.13.90:=[gnome-online-accounts]
	>=gnome-base/gnome-desktop-${PV%.}:3=
	media-libs/clutter:1.0
	media-libs/clutter-gtk:1.0
	media-libs/libchamplain:0.12
	>=net-libs/gnome-online-accounts-${PV%.*}:=[vala]
	>=net-libs/telepathy-glib-0.17.5
	>=sci-geosciences/geocode-glib-3.15.3
	x11-libs/cairo:=
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.24.12:3
	x11-libs/pango
	>=dev-libs/libhandy-0.0.12
	v4l? ( >=media-video/cheese-3.5.91:= )
"
DEPEND="${RDEPEND}
	${VALA_DEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/gnome-contacts-3.36.2_22ac2c6fecc98efd11d96dc3e04938b8777a3510.patch
	"${FILESDIR}"/gnome-contacts-3.36.2_mr109.patch
)

src_prepare() {
	vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dmanpage=true
		$(meson_use v4l cheese)
		$(meson_use telepathy)
		$(meson_use valadocs docs)
	)

	meson_src_configure
}

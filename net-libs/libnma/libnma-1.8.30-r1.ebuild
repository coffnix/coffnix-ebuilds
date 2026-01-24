# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"

inherit gnome3 meson vala

DESCRIPTION="NetworkManager GUI library"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libnma"

LICENSE="GPL-2+ FDL-1.1+"
SLOT="0"
KEYWORDS="*"
IUSE="gcr gtk4 +introspection +vala"

RDEPEND="
	!<=gnome-extra/nm-applet-1.8.24
	app-text/iso-codes
	net-misc/mobile-broadband-provider-info
	>=dev-libs/glib-2.62.2:2[dbus]
	>=dev-libs/gobject-introspection-1.62.0:=
	>=x11-libs/gtk+-3.24.12:3[introspection?]
	gcr? ( >=app-crypt/gcr-3.14:=[gtk] )
	>=net-misc/networkmanager-1.22.6[vala?]
"

DEPEND="${RDEPEND}
	$(vala_depend)
"

src_prepare() {
	vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk4 libnma_gtk4)
		$(meson_use gcr)
		$(meson_use introspection)
		$(meson_use vala vapi)
	)
	meson_src_configure
}

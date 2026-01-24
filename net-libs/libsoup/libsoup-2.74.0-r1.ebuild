# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"

inherit gnome.org meson vala xdg

DESCRIPTION="HTTP client/server library for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/libsoup"

LICENSE="LGPL-2.1+"
SLOT="2.4"

# TODO: Default enable brotli at some point? But in 2.70.0 not advertised to servers yet - https://gitlab.gnome.org/GNOME/libsoup/issues/146
IUSE="brotli gssapi gtk-doc +introspection samba ssl +vala"
REQUIRED_USE="vala? ( introspection )"

KEYWORDS="*"

DEPEND="
	>=dev-libs/glib-2.58:2
	>=dev-db/sqlite-3.8.2:3
	>=dev-libs/libxml2-2.9.1-r4:2
	brotli? ( >=app-arch/brotli-1.0.6-r1:= )
	>=net-libs/libpsl-0.20
	sys-libs/zlib
	gssapi? ( virtual/krb5 )
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
	samba? ( net-fs/samba )
"
RDEPEND="${DEPEND}
	>=net-libs/glib-networking-2.38.2[ssl?]
"
BDEPEND="
	dev-libs/glib
	dev-util/glib-utils
	gtk-doc? ( >=dev-util/gtk-doc-1.20
		app-text/docbook-xml-dtd:4.1.2 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_feature gssapi)
		-Dkrb5_config="${CHOST}-krb5-config"
		$(meson_feature samba ntlm)
		$(meson_feature brotli)
		-Dntlm_auth="${EPREFIX}/usr/bin/ntlm_auth"
		-Dtls_check=false # disables check, we still rdep on glib-networking
		-Dgnome=false
		$(meson_feature introspection)
		$(meson_feature vala vapi)
		$(meson_use gtk-doc gtk_doc)
		-Dtests=false
		-Dinstalled_tests=false
		-Dsysprof=disabled
	)
	meson_src_configure
}

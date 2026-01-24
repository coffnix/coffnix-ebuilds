# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"
VALA_USE_DEPEND="vapigen"

inherit gnome3 vala

DESCRIPTION="GNOME framework for accessing online accounts"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeOnlineAccounts"

LICENSE="LGPL-2+"
SLOT="0/1"
IUSE="debug gnome +introspection kerberos vala"
KEYWORDS="*"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=app-crypt/libsecret-0.5
	>=dev-libs/json-glib-0.16
	dev-libs/libxml2:2
	>=net-libs/libsoup-2.42:2.4
	net-libs/rest:0.7
	net-libs/telepathy-glib
	>=net-libs/webkit-gtk-2.7.2:4
	>=x11-libs/gtk+-3.24.12:3
	x11-libs/pango

	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	kerberos? (
		app-crypt/gcr:0=
		app-crypt/mit-krb5 )
"

PDEPEND="gnome? ( >=gnome-base/gnome-control-center-3.2[gnome-online-accounts(+)] )"

DEPEND="${RDEPEND}
	$(vala_depend)
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.3
	>=dev-util/intltool-0.50.1
	sys-devel/gettext
	virtual/pkgconfig

	dev-libs/gobject-introspection-common
	gnome-base/gnome-common
"

QA_CONFIGURE_OPTIONS=".*"

src_prepare() {
	gnome3_src_prepare
	vala_src_prepare
}

src_configure() {
	gnome3_src_configure \
		--disable-static \
		--enable-backend \
		--enable-documentation \
		--enable-exchange \
		--enable-facebook \
		--enable-flickr \
		--enable-foursquare \
		--enable-imap-smtp \
		--enable-lastfm \
		--enable-media-server \
		--enable-owncloud \
		--enable-pocket \
		--enable-telepathy \
		--enable-windows-live \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable kerberos) \
		$(use_enable introspection) \
		$(use_enable vala)
}

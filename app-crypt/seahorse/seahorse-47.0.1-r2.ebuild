# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit gnome3 meson vala

DESCRIPTION="Manage your passwords and encryption keys"
HOMEPAGE="https://gitlab.gnome.org/GNOME/seahorse"
SRC_URI="https://download.gnome.org/sources/seahorse/47/seahorse-47.0.1.tar.xz -> seahorse-47.0.1.tar.xz"
LICENSE="GPL-2+ FDL-1.1+"
SLOT="0"
KEYWORDS="*"
IUSE="X ldap zeroconf"
BDEPEND="$(vala_depend)
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/appstream-glib
	dev-libs/libxslt
	dev-util/gdbus-codegen
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
	
"
RDEPEND="dev-libs/glib:2
	app-crypt/gcr:0=[vala]
	app-crypt/gpgme:=
	x11-libs/gtk+:3[X?]
	app-crypt/gnupg
	dev-libs/libhandy[vala]
	app-crypt/libsecret[vala]
	dev-libs/libpwquality
	net-misc/openssh
	ldap? ( net-nds/openldap:= )
	net-libs/libsoup:3
	zeroconf? ( net-dns/avahi[dbus] )
	dev-libs/libxml2
	
"
DEPEND="${RDEPEND}
"
PATCHES=(
	# https://gitlab.gnome.org/GNOME/seahorse/-/issues/348
	"${FILESDIR}/${PN}-47.0.1-ldap-test.patch"
	# https://bugs.gentoo.org/961310
	"${FILESDIR}/${PN}-47.0.1-gpgme-2.patch"
)
src_prepare() {
	default
	vala_src_prepare
	gnome3_environment_reset
}
src_configure() {
	local emesonargs=(
	  -Dhelp=true
	  -Dpgp-support=true
	  -Dcheck-compatible-gpg=false 
	  -Dpkcs11-support=true
	  -Dkeyservers-support=true
	  -Dhkp-support=true
	  $(meson_use ldap ldap-support)
	  $(meson_use zeroconf key-sharing)
	  -Dmanpage=true
	)
	meson_src_configure
}
pkg_postinst() {
	gnome3_pkg_postinst
}
pkg_postrm() {
	gnome3_pkg_postrm
}


# vim: filetype=ebuild

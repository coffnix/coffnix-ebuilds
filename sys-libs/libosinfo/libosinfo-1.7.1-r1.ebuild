# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"

inherit gnome3 udev vala meson

DESCRIPTION="GObject library for managing information about real and virtual OSes"
HOMEPAGE="http://libosinfo.org/"
SRC_URI="https://releases.pagure.org/libosinfo/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"

IUSE="docs +introspection +vala test"
REQUIRED_USE="vala? ( introspection )"

KEYWORDS="*"

# Unsure about osinfo-db-tools rdep, but at least fedora does it too
RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=net-libs/libsoup-2.42:2.4
	>=dev-libs/libxml2-2.6.0
	>=dev-libs/libxslt-1.0.0
	sys-apps/hwids[pci,usb]
	sys-apps/osinfo-db-tools
	sys-apps/osinfo-db
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
# perl dep is for pod2man
DEPEND="${RDEPEND}
	dev-lang/perl
	dev-libs/gobject-introspection-common
	>=dev-util/gtk-doc-am-1.10
	>=dev-util/intltool-0.40.0
	virtual/pkgconfig
	test? ( dev-libs/check )
	vala? ( $(vala_depend) )
"

src_prepare() {
	gnome3_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dwith-usb-ids-path=/usr/share/misc/usb.ids
		-Dwith-pci-ids-path=/usr/share/misc/pci.ids
		-Denable-introspection=$(usex introspection enabled disabled)
		-Denable-vala=$(usex vala enabled disabled)
		$(meson_use docs enable-gtk-doc)
		$(meson_use test enable-tests)
	)

	meson_src_configure
}

# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"
# FIXME: Claims to works with python3 but appears to be wishful thinking
PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="xml"

inherit gnome3 python-r1 vala meson

DESCRIPTION="An object-oriented framework for creating UPnP devs and control points"
HOMEPAGE="https://wiki.gnome.org/Projects/GUPnP"

LICENSE="LGPL-2"
SLOT="1.2"
KEYWORDS="*"

IUSE="connman doc example +introspection kernel_linux networkmanager vala"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	?? ( connman networkmanager )
"

# prefix: uuid dependency can be adapted to non-linux platforms
RDEPEND="${PYTHON_DEPS}
	>=net-libs/gssdp-1.1.2:1.2=[introspection?]
	>=net-libs/libsoup-2.48.0:2.4[introspection?]
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libxml2-2.9.1-r4
	>=sys-apps/util-linux-2.24.1-r3
	introspection? (
			>=dev-libs/gobject-introspection-1.62.0:=
			$(vala_depend) )
	connman? ( >=dev-libs/glib-2.62.2:2 )
	networkmanager? ( >=dev-libs/glib-2.62.2:2 )
	!net-libs/gupnp-vala
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.14
	sys-devel/gettext
	>=virtual/pkgconfig-0-r1
"

src_prepare() {
	use introspection && vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local backend=unix
	use kernel_linux && backend=linux
	use connman && backend=connman
	use networkmanager && backend=network-manager

	ECONF_SOURCE=${S} \
	local emesonargs=(
		$(meson_use introspection introspection)
		$(meson_use doc gtk_doc)
		$(meson_use example examples)
		$(meson_use vala vapi)
		-Dcontext_manager=${backend}
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	einstalldocs
	python_foreach_impl python_doscript tools/gupnp-binding-tool-1.2
}

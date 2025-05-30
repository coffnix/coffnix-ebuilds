# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome.org meson

DESCRIPTION="Javascript bindings for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/Gjs"

LICENSE="MIT || ( MPL-1.1 LGPL-2+ GPL-2+ )"
SLOT="0"
IUSE="+cairo examples gtk readline"
KEYWORDS="*"

RDEPEND="
	>=dev-libs/glib-2.66.0
	dev-libs/libffi:=
	>=dev-libs/gobject-introspection-1.66.1:=
	dev-lang/spidermonkey:78
	cairo? ( x11-libs/cairo[X,svg] )
	readline? ( sys-libs/readline:0= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_configure() {
	sed -i 's/--warn-error//g' meson.build || die
	local emesonargs=(
		$(meson_feature cairo)
		$(meson_feature readline)
		-Dprofiler=disabled
		-Dinstalled_tests=false
		-Dskip_dbus_tests=true
		-Dskip_gtk_tests=true
		-Dwerror=false
	)
	meson_src_configure
}

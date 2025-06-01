# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"

inherit gnome3 vala meson

DESCRIPTION="Dominate the board in a classic version of Reversi"
HOMEPAGE="https://wiki.gnome.org/Apps/Iagno"

LICENSE="GPL-3+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2
	>=gnome-base/librsvg-2.32.0:2
	media-libs/gsound
	>=media-libs/libcanberra-0.26[gtk3]
	>=x11-libs/gtk+-3.24.12:3
"
RDEPEND="${COMMON_DEPEND}
	!<x11-themes/gnome-themes-standard-3.14
"
DEPEND="${COMMON_DEPEND}
	$(vala_depend)
	app-text/yelp-tools
	dev-libs/appstream-glib
	>=dev-util/intltool-0.50
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	# backport for https://gitlab.gnome.org/GNOME/gnome-nibbles/-/issues/52
	"${FILESDIR}"/${P}-vala-0.50.4-GtkChild-1.patch
	"${FILESDIR}"/${P}-vala-0.50.4-GtkChild-2.patch
)

src_prepare() {
	#default
	gnome3_src_prepare
	vala_src_prepare
}

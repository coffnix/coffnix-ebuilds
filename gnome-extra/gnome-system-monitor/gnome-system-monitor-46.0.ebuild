# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit gnome3 meson

DESCRIPTION="The Gnome System Monitor"
HOMEPAGE="https://help.gnome.org/users/gnome-system-monitor/"
#SRC_URI="https://download.gnome.org/sources/gnome-system-monitor/${P}/${PV}.tar.xz -> ${PV}.tar.xz"
#SRC_URI="https://download.gnome.org/sources/gnome-system-monitor/46/gnome-system-monitor-46.0.tar.xz"
SRC_URI="https://download.gnome.org/sources/${PN}/${PV%.*}/${P}.tar.xz"



LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="systemd X"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=gnome-base/libgtop-2.41.2
	>=x11-libs/gtk+-3.24.12:3[X(+)]
	>=dev-cpp/gtkmm-3.3.18:3.0
	>=dev-cpp/glibmm-2.62.0
	>=dev-cpp/atkmm-2.25.1
	>=dev-libs/libxml2-2.0:2
	>=gnome-base/librsvg-2.35:2
	systemd? ( >=sys-apps/systemd-44:0= )
	X? ( >=x11-libs/libwnck-2.91.0:3 )
"
# eautoreconf requires gnome-base/gnome-common
DEPEND="${RDEPEND}
	app-text/yelp-tools
	>=dev-util/intltool-0.41.0
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		$(meson_use systemd)
		$(meson_use X wnck)
	)

	meson_src_configure
}

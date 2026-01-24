# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.32"
PYTHON_COMPAT=( python3+ )

inherit autotools gnome3 meson python-any-r1 vala

DESCRIPTION="Library providing a virtual terminal emulator widget"
HOMEPAGE="https://wiki.gnome.org/action/show/Apps/Terminal/VTE"
SRC_URI="https://gitlab.gnome.org/GNOME/vte/-/archive/${PV}/vte-${PV}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="2.91"
# -std=gnu++20 required (gcc-11)
KEYWORDS="*"

IUSE="+crypt doc debug elogind glade +introspection +vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libpcre2-10.21
	>=x11-libs/gtk+-3.24.12:3[introspection?]
	>=dev-libs/fribidi-1.0.0
	>=x11-libs/pango-1.44.7
	sys-libs/zlib

	elogind? ( >=sys-auth/elogind-241.3 )
	crypt?  ( >=net-libs/gnutls-3.2.7:0= )
	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	x11-libs/pango[introspection?]
"
DEPEND="${RDEPEND}
	dev-util/gperf
	dev-libs/libxml2
	dev-util/gtk-doc
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig

	vala? ( $(vala_depend) )
"
RDEPEND="${RDEPEND}
	!x11-libs/vte:2.90[glade]
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.64.1-meson-Find-python-explicitly-to-honor-downstream-pyt.patch
	"${FILESDIR}"/${PN}-0.60.3-elogind-support.patch
)

src_prepare() {
	# -Ddebugg option enables various debug support via VTE_DEBUG, but also ggdb3; strip the latter
	sed -e '/ggdb3/d' -i meson.build || die

	use vala && vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		-Da11y=true
		$(meson_use debug debugg)
		$(meson_use doc docs)
		$(meson_use introspection gir)
		-Dfribidi=true # pulled in by pango anyhow
		$(meson_use crypt gnutls)
		-Dgtk3=true
		-Dgtk4=false
		$(meson_use elogind)
		-D_systemd=false
		-Dicu=true
		$(meson_use vala vapi)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	mv "${ED}"/etc/profile.d/vte{,-${SLOT}}.sh || die
}

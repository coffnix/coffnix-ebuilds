# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"
PYTHON_COMPAT=( python3+ )

inherit gnome3 python-any-r1 vala virtualx meson

DESCRIPTION="Libraries for cryptographic UIs and accessing PKCS#11 modules"
HOMEPAGE="https://git.gnome.org/browse/gcr"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0/1" # subslot = suffix of libgcr-3

IUSE="doc +gtk +introspection +vala"
REQUIRED_USE="vala? ( introspection )"

KEYWORDS="*"

COMMON_DEPEND="
	>=app-crypt/p11-kit-0.19
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libgcrypt-1.2.2:0=
	>=dev-libs/libtasn1-1:=
	>=sys-apps/dbus-1
	gtk? ( >=x11-libs/gtk+-3.24.12:3[X,introspection?] )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/gnome-keyring-3.3
"
# gcr was part of gnome-keyring until 3.3
DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	dev-libs/gobject-introspection-common
	dev-libs/libxslt
	dev-libs/vala-common
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

PATCHES=(
	"${FILESDIR}/${P}-vala.patch"
	"${FILESDIR}/${P}-meson-0.61-fix.patch"
	"${FILESDIR}/${P}-set-vapi-deps.patch"
)

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	use vala && vala_src_prepare
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk)
		$(meson_use doc gtk_doc)
		$(meson_use introspection)
		$(meson_use vala vapi)
	)

	meson_src_configure
}

src_test() {
	virtx emake check
}

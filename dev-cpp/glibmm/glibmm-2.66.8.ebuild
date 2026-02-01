# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome.org meson

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="2"
KEYWORDS="*"
IUSE="doc debug test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/libsigc++-2.9.1:2
	>=dev-libs/glib-2.62.2:2
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	>=dev-cpp/mm-common-1.0.0
	sys-devel/m4
	dev-lang/perl
	doc? (
		app-doc/doxygen
		dev-libs/libxslt
		media-gfx/graphviz
	)
"

src_prepare() {
	default

	# giomm_tls_client requires FEATURES=-network-sandbox and glib-networking rdep
	sed -i -e '/giomm_tls_client/d' tests/meson.build || die

	if ! use test; then
		sed -i -e "/^subdir('tests')/d" meson.build || die
	fi
}

src_configure() {
	local emesonargs=(
		-Dmaintainer-mode=true # Set false and drop mm-common dep once tarballs are made with meson/ninja
		-Dwarnings=min
		-Dbuild-deprecated-api=true
		-Dbuild-documentation=$(usex doc true false)
		-Ddebug-refcounting=$(usex debug true false)
		-Dbuild-examples=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	einstalldocs

	find examples -type d -name '.deps' -exec rm -rf {} \; 2>/dev/null
	find examples -type f -name 'Makefile*' -exec rm -f {} \; 2>/dev/null
	dodoc -r examples
}

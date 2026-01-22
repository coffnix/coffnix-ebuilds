# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"
VALA_USE_DEPEND="vapigen"
inherit autotools eutils gnome3 vala ltprune memsaver cargo

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"
SRC_URI="https://github.com/GNOME/librsvg/tarball/2f7db6161d09cdca8072a66a0bdfd64a46436bfd -> librsvg-2.54.7-2f7db61.tar.gz
https://distfiles.macaronios.org/41/90/a9/4190a9e4a47e4ebce777c3a47bb52c0e3d04c5a4c2a8f82532261de2d66ce180805ebe647590d7457ea7c681f7434b0bcab9257dbbd8cfcb19e886f0d23c36b5 -> librsvg-2.54.7-funtoo-crates-bundle-af10f4f29778cae8dc554b1e9fdb82daa1f95a2f951122554db0f54503538616d1d5ade3b84d13c745e9ad953c3b1c8d4949bb32d9ea368c341f6ad6594c1e2a.tar.gz"
LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="*"

S="${WORKDIR}/GNOME-librsvg-2f7db61"

IUSE="gtk-doc +introspection +vala"
REQUIRED_USE="gtk-doc? ( introspection ) vala? ( introspection )"
RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=x11-libs/cairo-1.16.0
	>=x11-libs/pango-1.44.7
	>=dev-libs/libxml2-2.9.1:2
	>=dev-libs/libcroco-0.6.8
	>=x11-libs/gdk-pixbuf-2.39.2:2[introspection?]
	>=virtual/rust-1.41
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
DEPEND="${RDEPEND}
	dev-libs/gobject-introspection-common
	dev-libs/vala-common
	gtk-doc? ( dev-util/gi-docgen )
	virtual/rust
	vala? ( $(vala_depend) )
	>=virtual/pkgconfig-0-r1
"

src_unpack() {
	cargo_src_unpack
}

src_prepare() {
	eautoreconf
	gnome3_src_prepare
	use vala && vala_src_prepare
}

src_configure() {
	memsaver_src_configure
	use vala && export PKG_CONFIG_PATH="${T}/pkgconfig:${PKG_CONFIG_PATH}"
	ECONF_SOURCE=${S} \
	gnome3_src_configure \
		--disable-debug \
		--disable-static \
		$(use_enable gtk-doc) \
		$(use_enable introspection) \
		$(use_enable vala) \
		--enable-pixbuf-loader

	ln -s "${S}"/doc/html doc/html || die
}

src_compile() {
	# causes segfault if set, see bug #411765
	unset __GL_NO_DSO_FINALIZER
	gnome3_src_compile
}

src_install() {
    gnome3_src_install
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	gnome3_pkg_postinst
}

pkg_postrm() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	gnome3_pkg_postrm
}

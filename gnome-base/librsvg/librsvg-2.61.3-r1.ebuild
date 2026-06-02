# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
VALA_USE_DEPEND="vapigen"
ECARGO_BUNDLE_POSTFIX="mark-rust-bundle"

inherit meson eutils gnome3 vala ltprune cargo multilib

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"
#SRC_URI="
#https://download.gnome.org/sources/librsvg/2.61/librsvg-2.61.3.tar.xz -> librsvg-2.61.3.tar.xz
#mirror://macaroni/librsvg-2.61.3-mark-rust-bundle.tar.xz -> librsvg-2.61.3-mark-rust-bundle.tar.xz"
SRC_URI="
https://download.gnome.org/sources/librsvg/2.61/librsvg-2.61.3.tar.xz -> librsvg-2.61.3.tar.xz
https://distfiles.macaronios.org/XX/XX/XX/HASH_DO_BUNDLE_CORRETO -> librsvg-2.61.3-mark-rust-bundle.tar.xz"
LICENSE="LGPL+2"
SLOT="2"
KEYWORDS="*"
IUSE="gtk-doc +introspection +vala"

RDEPEND="dev-libs/glib:2
	x11-libs/cairo
	x11-libs/pango
	dev-libs/libxml2:2
	dev-libs/libcroco
	x11-libs/gdk-pixbuf:2[introspection?]
	virtual/rust
	introspection? ( dev-libs/gobject-introspection:= )
"
DEPEND="${RDEPEND}
	dev-libs/gobject-introspection-common
	dev-libs/vala-common
	gtk-doc? ( dev-util/gi-docgen )
	vala? ( $(vala_depend) )
	virtual/pkgconfig
	dev-util/cargo-c
"

src_unpack() {
	cargo_src_unpack
}

src_prepare() {
	gnome3_src_prepare
	use vala && vala_src_prepare
	default
}

src_configure() {
	local emesonargs=(
		-Dtests=false
		-Davif=disabled
		$(meson_feature introspection)
		-Dpixbuf=enabled
		-Dpixbuf-loader=enabled
		$(meson_feature gtk-doc docs)
		$(meson_feature vala)
	)
	meson_src_configure
}

src_compile() {
	export CARGO_NET_OFFLINE=false
	meson_src_compile
}

src_install() {
	meson_src_install

	# See mark-issues/issues#579
	# Add link to fix upstream bug
	local loaderdir="/usr/$(get_libdir)/gdk-pixbuf-2.0/2.10.0/loaders"

	dosym "${loaderdir}/libpixbufloader_svg.so" \
		"${loaderdir}/libpixbufloader-svg.so"
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	gnome3_pkg_postrm
}

# vim: filetype=ebuild

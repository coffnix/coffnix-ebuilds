# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
VALA_USE_DEPEND="vapigen"
ECARGO_BUNDLE_POSTFIX="mark-rust-bundle"

inherit cargo meson eutils gnome3 vala ltprune multilib

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg https://gitlab.gnome.org/GNOME/librsvg"
SRC_URI="
https://download.gnome.org/sources/librsvg/2.62/librsvg-2.62.2.tar.xz -> librsvg-2.62.2.tar.xz
https://github.com/gentoo-crate-dist/librsvg/releases/download/2.62.2/librsvg-2.62.2-crates.tar.xz -> librsvg-2.62.2-mark-rust-bundle.tar.xz"
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

	sed -i \
		-e '/"ci",/d' \
		Cargo.toml || die

	default
}

src_configure() {
	local emesonargs=(
		-Dtests=false
		-Davif=disabled
		$(meson_feature introspection)
		-Dpixbuf=enabled
		-Dpixbuf-loader-cache=false
		-Dpixbuf-loader=enabled
		$(meson_feature gtk-doc docs)
		$(meson_feature vala)
	)

	meson_src_configure || die
}

src_compile() {
	meson_src_compile || die
}

src_install() {
	meson_src_install || die

	local loaderdir="/usr/$(get_libdir)/gdk-pixbuf-2.0/2.10.0/loaders"

	if [[ -e "${ED}${loaderdir}/libpixbufloader_svg.so" && ! -e "${ED}${loaderdir}/libpixbufloader-svg.so" ]]; then
		dosym "${loaderdir}/libpixbufloader_svg.so" \
			"${loaderdir}/libpixbufloader-svg.so"
	fi
}

pkg_postinst() {
	unset __GL_NO_DSO_FINALIZER
	gnome3_pkg_postinst
}

pkg_postrm() {
	unset __GL_NO_DSO_FINALIZER
	gnome3_pkg_postrm
}

# vim: filetype=ebuild

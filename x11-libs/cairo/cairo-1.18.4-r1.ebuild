# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit meson python-any-r1

SRC_URI="https://gitlab.freedesktop.org/cairo/cairo/-/archive/${PV}/cairo-${PV}.tar.bz2"
KEYWORDS="*"

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="https://www.cairographics.org/ https://gitlab.freedesktop.org/cairo/cairo"
LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
IUSE="X aqua debug +glib gtk-doc lzo test +svg +harfbuzz"
# Tests need more wiring up like e.g. https://gitlab.freedesktop.org/cairo/cairo/-/blob/master/.gitlab-ci.yml
# any2ppm tests seem to hang for now.
RESTRICT="test !test? ( test )"

RDEPEND="
	>=media-libs/fontconfig-2.13.92
	>=media-libs/freetype-2.13:2[png]
	>=media-libs/libpng-1.6.10:0
	>=sys-libs/zlib-1.2.8-r1
	>=x11-libs/pixman-0.42.3
	debug? ( sys-libs/binutils-libs:0 )
	glib? ( >=dev-libs/glib-2.34.3:2 )
	lzo? ( >=dev-libs/lzo-2.06-r1:2 )
	X? (
		>=x11-libs/libXrender-0.9.8
		>=x11-libs/libXext-1.3.2
		>=x11-libs/libX11-1.6.2
		>=x11-libs/libxcb-1.9.1
	)
"
DEPEND="${RDEPEND}
	test? (
		app-text/ghostscript-gpl
		app-text/poppler[cairo]
		gnome-base/librsvg
	)
	X? ( x11-base/xorg-proto )
"

BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )"

PATCHES=(
	"${FILESDIR}"/${PN}-respect-fontconfig.patch
)

src_configure() {
	local emesonargs=(
		-Ddwrite=disabled
		-Dfontconfig=enabled
		-Dfreetype=enabled
		-Dpng=enabled
		$(meson_feature aqua quartz)
		$(meson_feature X tee)
		$(meson_feature X xcb)
		$(meson_feature X xlib)
		-Dxlib-xcb=disabled
		-Dzlib=enabled

		# Requires poppler-glib (poppler[cairo]) which isn't available in multilib
		$(meson_native_use_feature test tests)

		$(meson_feature lzo)
		-Dgtk2-utils=disabled

		$(meson_feature glib)
		-Dspectre=disabled # only used for tests
		$(meson_feature debug symbol-lookup)

		$(meson_use gtk-doc gtk_doc)
	)

	meson_src_configure
}

src_test() {
	meson_src_test
}

src_install_all() {
	einstalldocs

	if use gtk-doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/cairo || die
		mv "${ED}"/usr/share/gtk-doc/{html/cairo,cairo/html} || die
		rmdir "${ED}"/usr/share/gtk-doc/html || die
	fi
}

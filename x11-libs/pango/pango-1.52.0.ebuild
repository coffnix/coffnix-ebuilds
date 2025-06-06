# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic gnome2-utils meson multilib-minimal toolchain-funcs xdg

DESCRIPTION="Internationalized text layout and rendering library"
HOMEPAGE="https://www.pango.org/ https://gitlab.gnome.org/GNOME/pango"
SRC_URI="https://download.gnome.org/sources/pango/1.52/pango-1.52.0.tar.xz -> pango-1.52.0.tar.xz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="debug doc +introspection sysprof X"

RDEPEND="
	>=dev-libs/glib-2.62.2:2[${MULTILIB_USEDEP}]
	>=dev-libs/fribidi-1.0.6[${MULTILIB_USEDEP}]
	>=media-libs/harfbuzz-2.2.0:=[glib(+),introspection?,truetype(+),${MULTILIB_USEDEP}]
	>=media-libs/fontconfig-2.12.92:1.0=[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.12.10:=[X?,${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.5.0.1:2=[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
	X? (
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXft-2.3.1-r1[${MULTILIB_USEDEP}]
		>=x11-libs/libXrender-0.9.8[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}
	sysprof? ( >=dev-util/sysprof-capture-3.40.1:4[${MULTILIB_USEDEP}] )
	X? ( x11-base/xorg-proto )
"
BDEPEND="
	dev-util/glib-utils
	sys-apps/help2man
	virtual/pkgconfig
"

src_prepare() {
	xdg_src_prepare
	gnome2_environment_reset
}

multilib_src_configure() {
	if use debug; then
		append-cflags -DPANGO_ENABLE_DEBUG
	else
		append-cflags -DG_DISABLE_CAST_CHECKS
	fi

	local emesonargs=(
		# Never use gi-docgen subproject
		--wrap-mode nofallback

		-Dgtk_doc=false # we ship pregenerated docs
		-Dlibthai=disabled
		-Dinstall-tests=false

		-Dcairo=enabled
		-Dfontconfig=enabled
		-Dfreetype=enabled

		$(meson_feature introspection)
		$(meson_feature sysprof)
		$(meson_feature X xft)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install

	if use doc; then
		insinto /usr/share/gtk-doc/html
		doins -r "${S}"/docs/Pango*
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	if has_version 'media-libs/freetype[-harfbuzz]' ; then
		ewarn "media-libs/freetype is installed without harfbuzz support. This may"
		ewarn "lead to minor font rendering problems, see bug 712374."
	fi
}

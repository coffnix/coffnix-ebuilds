# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit flag-o-matic meson python-any-r1 xdg-utils

DESCRIPTION="HarfBuzz text shaping engine"
HOMEPAGE="https://github.com/harfbuzz/harfbuzz"
SRC_URI="https://github.com/harfbuzz/harfbuzz/tarball/4318985386e0a00d5bcdee8555012848a1124ff9 -> harfbuzz-11.2.1-4318985.tar.gz"

LICENSE="Old-MIT ISC icu"
KEYWORDS="*"
SLOT="0"

IUSE="+cairo debug doc experimental +glib +graphite icu +introspection test +truetype"
RESTRICT="!test? ( test )"
REQUIRED_USE="introspection? ( glib )"

RDEPEND="
	cairo? ( x11-libs/cairo )
	glib? ( >=dev-libs/glib-2.38:2 )
	graphite? ( >=media-gfx/graphite2-1.2.1 )
	icu? ( >=dev-libs/icu-52 )
	introspection? ( >=dev-libs/gobject-introspection-1.34:= )
	truetype? ( >=media-libs/freetype-2.5.0.1:2= )
"
DEPEND="${RDEPEND}
	>=dev-libs/gobject-introspection-common-1.34
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc )
	introspection? ( dev-util/glib-utils )
"

post_src_unpack() {
	if [ ! -d "${S}" ] ; then
	mv "${WORKDIR}"/harfbuzz-harfbuzz-* "${S}" || die
	fi
}

pkg_setup() {
	python-any-r1_pkg_setup
	if ! use debug ; then
		append-cppflags -DHB_NDEBUG
	fi
}

src_prepare() {
	default
	xdg_environment_reset

}

src_configure() {
	# harfbuzz-gobject only used for introspection, bug #535852
	local emesonargs=(
		-Dcoretext="disabled"
		-Dchafa="disabled"

		$(meson_feature glib)
		$(meson_feature graphite graphite2)
		$(meson_feature icu)
		$(meson_feature introspection gobject)
		$(meson_feature test tests)
		$(meson_feature truetype freetype)

		$(meson_native_use_feature cairo)
		$(meson_native_use_feature doc docs)
		$(meson_native_use_feature introspection)

		$(meson_use experimental experimental_api)
	)
	meson_src_configure
}
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome.org flag-o-matic meson

DESCRIPTION="C++ interface for the ATK library"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="1"
KEYWORDS="*"
IUSE="doc"

# IMPORTANT: atkmm, glibmm and pangomm need to be treated as a logical set.
# Make sure pangomm and atkmm are using the same glibmm version! Otherwise
# deps get unpleasant.

COMMON_DEPEND="
	>=dev-cpp/glibmm-2.62.0[doc?]
	>=dev-libs/atk-2.18.0
	>=dev-libs/libsigc++-2.3.2:2
"
RDEPEND="${COMMON_DEPEND}
	!<dev-cpp/gtkmm-2.22.0
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
append-cxxflags "-std=c++17"

#src_configure() {
#	econf \
#	ECONF_SOURCE="${S}" \
#	$(use_enable doc documentation)
#}


multilib_src_configure() {
    local emesonargs=(
        -Dbuild-atkmm-api=true
        -Dbuild-demos=false
        $(meson_native_use_bool gtk-doc build-documentation)
        $(meson_use test build-tests)
        $(meson_use X build-x11-api)
    )
    meson_src_configure
}

src_test() {
	virtx emake check
}

src_install() {
	meson_src_install
}

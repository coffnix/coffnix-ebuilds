# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Wayland protocol files"
HOMEPAGE="https://wayland.freedesktop.org/"
SRC_URI="https://gitlab.freedesktop.org/wayland/wayland-protocols/-/archive/1.44/wayland-protocols-1.44.tar.bz2 -> wayland-protocols-1.44.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RESTRICT="!test? ( test )"

DEPEND="
	test? ( dev-libs/wayland )
"
RDEPEND=""
BDEPEND="
	dev-util/wayland-scanner
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		$(meson_use test tests)
	)
	meson_src_configure
}
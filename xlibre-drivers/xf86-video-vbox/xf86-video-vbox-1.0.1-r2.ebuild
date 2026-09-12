# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools linux-info flag-o-matic

DESCRIPTION="Driver for xorg-server"
KEYWORDS="*"
IUSE=" "
SRC_URI="https://gitlab.freedesktop.org/xorg/driver/xf86-video-vbox/-/archive/xf86-video-vboxvideo-1.0.1/xf86-video-vbox-xf86-video-vboxvideo-1.0.1.tar.bz2 -> xf86-video-vbox-1.0.1-gitlab.tar.bz2"
SLOT="0"
S="$WORKDIR/${PN}-xf86-video-vboxvideo-${PV}"
DEPEND="
	x11-base/xorg-proto
	xlibre-base/xorg-server
	>=sys-devel/libtool-2.2.6a
	sys-devel/m4
	>=x11-misc/util-macros-1.18
	
"

RDEPEND="
	${DEPEND}x11-libs/libpciaccess
	x11-libs/libXcomposite

"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
AUTOTOOLS_AUTORECONF="1"

pkg_setup() {
	append-ldflags -Wl,-z,lazy
}
src_prepare() {
	eautoreconf || die
	default
}


src_install() {
	default
	find "${D}" -type f -name '*.la' -delete || die
}

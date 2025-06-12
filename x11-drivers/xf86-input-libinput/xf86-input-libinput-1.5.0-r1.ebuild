# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools linux-info flag-o-matic

DESCRIPTION="Driver for xorg-server"
KEYWORDS="*"
IUSE=" "
#SRC_URI="https://gitlab.freedesktop.org/xorg/driver/xf86-input-libinput/-/archive/xf86-input-libinput-1.4.0/xf86-input-libinput-xf86-input-libinput-1.4.0.tar.bz2 -> xf86-input-libinput-1.4.0-gitlab.tar.bz2"
SRC_URI="https://gitlab.freedesktop.org/xorg/driver/${PN}/-/archive/${P}/${PN}-${P}.tar.bz2 -> ${P}-gitlab.tar.bz2"
SLOT="0"
S="$WORKDIR/${PN}-${P}"
DEPEND="
	x11-base/xorg-proto
	|| (
        >=x11-base/xorg-server-1.15.1
        >=x11libre-base/xorg-server-1.15.1
    )
	>=sys-devel/libtool-2.2.6a
	sys-devel/m4
	>=x11-misc/util-macros-1.18
	>=dev-libs/libinput-1.5.0:0=

"

RDEPEND="
	${DEPEND}
	
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
	# See FL-7952: Make libinput take priority over synaptics.
	(cd ${D}/usr/share/X11/xorg.conf.d/ && mv 40-libinput.conf 80-libinput.conf) || die
	
}

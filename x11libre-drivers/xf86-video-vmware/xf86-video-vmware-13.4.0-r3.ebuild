# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools linux-info flag-o-matic git-r3

DESCRIPTION="Driver for xorg-server"
KEYWORDS="*"
IUSE=" "
#SRC_URI="https://gitlab.freedesktop.org/xorg/driver/xf86-video-vmware/-/archive/xf86-video-vmware-13.4.0/xf86-video-vmware-xf86-video-vmware-13.4.0.tar.bz2 -> xf86-video-vmware-13.4.0-gitlab.tar.bz2"
SLOT="0"
#S="$WORKDIR/${PN}-${P}"
EGIT_REPO_URI="https://github.com/X11Libre/xf86-video-vmware.git"
EGIT_BRANCH="master"
SRC_URI=""
DEPEND="
	x11-base/xorg-proto
	|| (
        >=x11-base/xorg-server-1.15.1
        >=x11libre-base/xorg-server-1.15.1
    )
	>=sys-devel/libtool-2.2.6a
	sys-devel/m4
	>=x11-misc/util-macros-1.18

	|| (
        x11-base/xorg-server[-minimal]
        x11libre-base/xorg-server[-minimal]
    )
	x11-libs/libdrm
"

RDEPEND="
	${DEPEND}x11-libs/libpciaccess
	x11-libs/libdrm[libkms,video_cards_vmware]
|| (
  media-libs/mesa[xa]
  media-libs/mesa[video_cards_xa]
)

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

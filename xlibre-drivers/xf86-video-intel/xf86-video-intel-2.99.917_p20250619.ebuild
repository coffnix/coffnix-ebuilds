# Distributed under the terms of the GNU General Public License v2

EAPI=7

XORG_DRI=dri
XORG_EAUTORECONF=yes
inherit linux-info xorg-3 flag-o-matic git-r3

KEYWORDS="*"
#COMMIT_ID="31486f40f8e8f8923ca0799aea84b58799754564"
#SRC_URI="https://gitlab.freedesktop.org/xorg/driver/xf86-video-intel/-/archive/${COMMIT_ID}/${P}.tar.bz2"
#S="${WORKDIR}/${PN}-${COMMIT_ID}"
EGIT_REPO_URI="https://github.com/X11Libre/xf86-video-intel.git"
EGIT_BRANCH="master"
SRC_URI=""

DESCRIPTION="X.Org driver for Intel cards"

IUSE="debug sna tools +udev +uxa xvmc"

REQUIRED_USE="
	|| ( sna uxa )
"
RDEPEND="
	x11-libs/libdrm[video_cards_intel]
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXScrnSaver
	>=x11-libs/pixman-0.27.1
	|| (
        >=x11-base/xorg-server-1.15.1
        >=xlibre-base/xorg-server-1.15.1
    )
	!<=media-libs/mesa-12.0.4
	tools? (
		x11-libs/libX11
		x11-libs/libxcb
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libxshmfence
		x11-libs/libXtst
	)
	udev? (
		virtual/libudev:=
	)
	xvmc? (
		x11-libs/libXvMC
		>=x11-libs/libxcb-1.5
		x11-libs/xcb-util
	)
"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"

PATCHES=(
	"${FILESDIR}"/${PN}-gcc-pr65873.patch
)

src_configure() {
	replace-flags -Os -O2
	XORG_CONFIGURE_OPTIONS=(
		--disable-dri1
		--disable-backlight
		--disable-backlight-helper
		$(use_enable debug)
		$(use_enable dri)
		$(use_enable dri dri3)
		$(usex dri "--with-default-dri=3")
		$(use_enable sna)
		$(use_enable tools)
		$(use_enable udev)
		$(use_enable uxa)
		$(use_enable xvmc)
	)
	xorg-3_src_configure
}

pkg_postinst() {
	if linux_config_exists && \
		kernel_is -lt 4 3 && ! linux_chkconfig_present DRM_I915_KMS; then
		echo
		ewarn "This driver requires KMS support in your kernel"
		ewarn "  Device Drivers --->"
		ewarn "    Graphics support --->"
		ewarn "      Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)  --->"
		ewarn "      <*>   Intel 830M, 845G, 852GM, 855GM, 865G (i915 driver)  --->"
		ewarn "	      i915 driver"
		ewarn "      [*]       Enable modesetting on intel by default"
		echo
	fi
}

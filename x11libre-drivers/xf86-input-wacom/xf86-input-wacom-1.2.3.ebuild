# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info udev xorg-3 meson git-r3

DESCRIPTION="Driver for Wacom tablets and drawing devices"
HOMEPAGE="https://linuxwacom.github.io/"
#SRC_URI="https://github.com/linuxwacom/${PN}/releases/download/${P}/${P}.tar.bz2"
EGIT_REPO_URI="https://github.com/X11Libre/xf86-input-wacom.git"
SRC_URI=""
EGIT_BRANCH="master"

LICENSE="GPL-2+"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-python/evdev
	dev-python/libevdev
	dev-python/pytest
	dev-python/exceptiongroup
	dev-python/attrs
	"
RDEPEND="
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXinerama
	virtual/libudev:="
DEPEND="${RDEPEND}"

pkg_pretend() {
	linux-info_pkg_setup

	if ! linux_config_exists \
			|| ! linux_chkconfig_present HID_WACOM; then
		echo
		ewarn "If you use a USB Wacom tablet, you need to enable support in your kernel"
		ewarn "  Device Drivers --->"
		ewarn "    HID support  --->"
		ewarn "      Special HID drivers  --->"
		ewarn "        <*> Wacom Intuos/Graphire tablet support (USB)"
		echo
	fi
}

pkg_setup() {
	linux-info_pkg_setup
}

#src_configure() {
#	xorg-3_flags_setup
#
#	local emesonargs=(
#		-Dsystemd-unit-dir="$(systemd_get_systemunitdir)"
#		-Dudev-rules-dir="$(get_udevdir)/rules.d"
#		$(meson_feature test unittests)
#		-Dwacom-gobject=disabled
#	)
#	meson_src_configure
#}

src_configure() {
    xorg-3_flags_setup

    local emesonargs=(
        --libdir=lib64
    )

    meson_src_configure
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}

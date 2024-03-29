# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit mount-boot

# Go to e.g. https://github.com/raspberrypi/firmware/tree/1.20211029/modules
# for the latest tag to see which kernel version it corresponds to.

DESCRIPTION="Raspberry Pi (all versions) kernel and modules"
HOMEPAGE="https://github.com/raspberrypi/firmware"
LICENSE="GPL-2 raspberrypi-videocore-bin"
SLOT="0"
RESTRICT="binchecks strip"

# Temporary safety measure to prevent ending up with a pair of
# sys-kernel/raspberrypi-image and sys-boot/raspberrypi-firmware
# both of which installed device tree files.
# Restore to simply "sys-boot/raspberrypi-firmware" when the mentioned version
# and all older ones are deleted.
RDEPEND=">sys-boot/raspberrypi-firmware-1.20190709"

[[ "$(ver_cut 4)" == 'p' ]] || die "Unsupported version format, tweak the ebuild."
MY_PV="1.$(ver_cut 5)"
SRC_URI="https://github.com/raspberrypi/firmware/archive/${MY_PV}.tar.gz -> raspberrypi-firmware-${MY_PV}.tar.gz"
S="${WORKDIR}/firmware-${MY_PV}"
KEYWORDS="arm arm64"

src_install() {
	insinto /lib/modules
	doins -r modules/*
	insinto /boot
	doins boot/*.img

	doins boot/*.dtb
	doins -r boot/overlays
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Firmware files for CIX Sky1 SoC, Radxa Orion O6 and compatible boards"
HOMEPAGE="https://github.com/Sky1-Linux/sky1-firmware"
EGIT_REPO_URI="https://github.com/Sky1-Linux/sky1-firmware.git"
EGIT_COMMIT="v${PV}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	insinto /lib/firmware
	doins -r firmware/.
}

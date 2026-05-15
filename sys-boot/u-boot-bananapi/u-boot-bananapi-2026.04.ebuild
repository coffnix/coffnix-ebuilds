# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit git-r3 toolchain-funcs

DESCRIPTION="Das U-Boot bootloader for Banana Pi family boards"
HOMEPAGE="https://www.denx.de/wiki/U-Boot https://github.com/u-boot/u-boot"

EGIT_REPO_URI="https://github.com/u-boot/u-boot.git"
EGIT_COMMIT="v${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

BDEPEND="
	app-arch/cpio
	dev-lang/perl
	sys-devel/bc
	sys-devel/binutils
	sys-devel/bison
	sys-devel/flex
	sys-devel/make
	>=sys-libs/ncurses-5.2
	virtual/libelf
	dev-lang/swig
	virtual/pkgconfig
	sys-apps/dtc
	dev-vcs/git
"

pkg_setup() {
	case "$(uname -m)" in
		armv7l|armv6l)
			;;
		*)
			die "u-boot-bananapi requires native ARM 32-bit, armv7l or armv6l, current arch: $(uname -m)"
			;;
	esac
}

build_uboot() {
	local defconfig="${1}"
	local output="${2}"

	emake distclean

	emake \
		HOSTCC="$(tc-getBUILD_CC)" \
		"${defconfig}"

	tc-ld-force-bfd

	emake \
		HOSTCC="$(tc-getBUILD_CC)"

	cp u-boot-sunxi-with-spl.bin "${output}" || die
}

src_compile() {
	build_uboot Bananapi_defconfig Bananapi-u-boot-sunxi-with-spl.bin
	build_uboot Bananapro_defconfig Bananapro-u-boot-sunxi-with-spl.bin
	build_uboot bananapi_m1_plus_defconfig Bananapi_m1_plus-u-boot-sunxi-with-spl.bin
}

src_install() {
	insinto /usr/lib/u-boot-bananapi

	doins Bananapi-u-boot-sunxi-with-spl.bin
	doins Bananapro-u-boot-sunxi-with-spl.bin
	doins Bananapi_m1_plus-u-boot-sunxi-with-spl.bin
}

pkg_postinst() {
	elog "U-Boot Banana Pi binaries installed into /usr/lib/u-boot-bananapi/"
	elog ""
	elog "Banana Pi:"
	elog "dd if=/usr/lib/u-boot-bananapi/Bananapi-u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8"
	elog ""
	elog "Banana Pro:"
	elog "dd if=/usr/lib/u-boot-bananapi/Bananapro-u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8"
	elog ""
	elog "Banana Pi M1 Plus:"
	elog "dd if=/usr/lib/u-boot-bananapi/Bananapi_m1_plus-u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8"
	}

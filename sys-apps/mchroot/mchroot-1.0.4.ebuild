# Distributed under the terms of the Apache License 2.0

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1 git-r3

DESCRIPTION="MacaroniOS hybrid chroot tool for cross-architecture environments"
HOMEPAGE="https://github.com/coffnix/mchroot"

EGIT_REPO_URI="https://github.com/coffnix/mchroot.git"
EGIT_COMMIT="${PV}"
#EGIT_BRANCH="main"

DEPEND=""
RDEPEND="
	app-emulation/qemu[static-user,qemu_user_targets_aarch64,qemu_user_targets_arm,qemu_user_targets_riscv64,qemu_user_targets_ppc64]
	dev-libs/glib[static-libs]
	sys-apps/attr[static-libs]
	sys-libs/zlib[static-libs]
	dev-libs/libpcre[static-libs]"

IUSE=""
SLOT="0"
LICENSE="Apache-2.0"
KEYWORDS="*"

src_install() {
	distutils-r1_src_install
	cp COPYRIGHT.txt man/COPYRIGHT.txt || die
	rst2man man/mchroot.1.rst.in > mchroot.1 || die
	doman mchroot.1
}

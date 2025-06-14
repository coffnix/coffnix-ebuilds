# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit meson multilib-minimal flag-o-matic udev python-any-r1

DESCRIPTION="An interface for filesystems implemented in userspace"
HOMEPAGE="https://github.com/libfuse/libfuse"
SRC_URI="https://github.com/libfuse/libfuse/releases/download/${P}/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="3"
KEYWORDS="*"
IUSE="test"

DEPEND="virtual/pkgconfig
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/pytest[${PYTHON_USEDEP}]')
	)"
RDEPEND=">=sys-fs/fuse-common-3.3.0-r1"

DOCS=( AUTHORS ChangeLog.rst README.md doc/README.NFS doc/kernel.txt )

PATCHES=(
	"${FILESDIR}"/fuse-3.6.1-no-mknod-on-install.patch
)

python_check_deps() {
	has_version "dev-python/pytest[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	default

	# lto not supported yet -- https://github.com/libfuse/libfuse/issues/198
	filter-flags -flto*

	# passthough_ll is broken on systems with 32-bit pointers
	cat /dev/null > example/meson.build || die
}

multilib_src_configure() {
	meson_src_configure
}

multilib_src_compile() {
	eninja
}

multilib_src_test() {
	${EPYTHON} -m pytest test || die
}

multilib_src_install() {
	DESTDIR="${D}" eninja install
}

multilib_src_install_all() {
	einstalldocs

	# installed via fuse-common
	rm -r "${ED}"/{etc,$(get_udevdir)} || die

	# manually install man pages to respect compression
	rm -r "${ED}"/usr/share/man || die
	doman doc/{fusermount3.1,mount.fuse3.8}
}

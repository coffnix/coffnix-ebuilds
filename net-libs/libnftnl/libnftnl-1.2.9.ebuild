# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools linux-info toolchain-funcs

DESCRIPTION="Netlink API to the in-kernel nf_tables subsystem"
HOMEPAGE="https://www.netfilter.org/projects/libnftnl/"
SRC_URI="https://www.netfilter.org/pub/libnftnl/libnftnl-1.2.9.tar.xz -> libnftnl-1.2.9.tar.xz
"

LICENSE="GPL-2"
SLOT="0/11" # libnftnl.so version
KEYWORDS="*"
IUSE="examples static-libs test"

RDEPEND=">=net-libs/libmnl-1.0.4"
BDEPEND="virtual/pkgconfig"
DEPEND="${RDEPEND}"

pkg_setup() {
	if kernel_is ge 3 13; then
		CONFIG_CHECK="~NF_TABLES"
		linux-info_pkg_setup
	else
		eerror "This package requires kernel version 3.13 or newer to work properly."
	fi
}

src_configure() {
	local myeconfargs=(
		$(use_enable static-libs static)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	gen_usr_ldscript -a nftnl
	find "${ED}" -type f -name '*.la' -delete || die

	if use examples; then
		find examples/ -name 'Makefile*' -delete || die "Could not rm examples"
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
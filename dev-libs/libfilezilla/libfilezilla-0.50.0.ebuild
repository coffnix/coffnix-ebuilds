# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools flag-o-matic

DESCRIPTION="C++ library offering some basic functionality for platform-independent programs"
HOMEPAGE="https://lib.filezilla-project.org/"
SRC_URI="https://dl4.cdn.filezilla-project.org/libfilezilla/libfilezilla-0.50.0.tar.xz?h=d7tJOJ-Uzue8Lwi4ulI34w&x=1748136097 -> libfilezilla-0.50.0_src.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/nettle:0=
	>=net-libs/gnutls-3.5.7:="
DEPEND="${RDEPEND}
	test? ( dev-util/cppunit )"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if ! test-flag-CXX -std=c++14; then
			eerror "${P} requires C++14-capable C++ compiler. Your current compiler"
			eerror "does not seem to support -std=c++14 option. Please upgrade your compiler"
			eerror "to gcc-4.9 or an equivalent version supporting C++14."
			die "Currently active compiler does not support -std=c++14"
		fi
	fi
}

src_configure() {
	# GMP patch
	perl -0pe 's/PKG_CHECK_MODULES\(\[GMP\].*\n.*\n.*//' "${S}"/configure.ac > ${S}/configure.ac.new
	mv ${S}/configure.ac.new ${S}/configure.ac

	eautoconf || die

	if use ppc || use arm || use hppa; then
		# bug 727652
		append-libs -latomic
	fi
	econf --disable-static || die
}

src_install() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}

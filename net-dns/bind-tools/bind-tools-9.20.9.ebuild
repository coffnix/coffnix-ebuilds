# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic toolchain-funcs

MY_PN=${PN//-tools}
MY_PV=${PV/_p/-P}
MY_PV=${MY_PV/_rc/rc}
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="bind tools: dig, nslookup, host, nsupdate, dnssec-keygen"
HOMEPAGE="https://www.isc.org/software/bind"
SRC_URI="https://downloads.isc.org/isc/bind9/9.20.9/bind-9.20.9.tar.xz -> bind-9.20.9.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 GPL-2 HPND ISC MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="doc gssapi idn ipv6 libedit readline xml"
# no PKCS11 currently as it requires OpenSSL to be patched, also see bug 409687

COMMON_DEPEND="
	dev-libs/libuv:=
	dev-libs/openssl:=
	dev-libs/userspace-rcu
	sys-libs/libcap
	xml? ( dev-libs/libxml2 )
	idn? ( net-dns/libidn2:= )
	gssapi? ( virtual/krb5 )
	libedit? ( dev-libs/libedit )
	!libedit? (
		readline? ( sys-libs/readline:= )
	)
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}
	!<=net-dns/bind-9.18.1-r2
"

# sphinx required for man-page and html creation
BDEPEND="
	doc? ( dev-python/sphinx )
	virtual/pkgconfig
"

S="${WORKDIR}/${MY_P}"

# bug 479092, requires networking
RESTRICT="test"

src_prepare() {
	default

	export LDFLAGS="${LDFLAGS} -L${EPREFIX}/usr/$(get_libdir)"

	# Disable tests for now, bug 406399
	sed -i '/^SUBDIRS/s:tests::' bin/Makefile.in lib/Makefile.in || die

	# bug #220361
	rm aclocal.m4 || die
	rm -rf libtool.m4/ || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--localstatedir="${EPREFIX}"/var
		--without-json-c
		--without-zlib
		--without-lmdb
		--without-maxminddb
		--disable-geoip
		--with-openssl="${ESYSROOT}"/usr
		$(use_with idn libidn2 "${ESYSROOT}"/usr)
		$(use_with xml libxml2)
		$(use_with gssapi)
		AR="$(type -P $(tc-getAR))"
	)

	# bug 607400
	if use libedit ; then
		myeconfargs+=( --with-readline=libedit )
	elif use readline ; then
		myeconfargs+=( --with-readline=readline )
	else
		myeconfargs+=( --without-readline )
	fi

	# bug 344029
	append-cflags "-DDIG_SIGCHASE"

	# to expose CMSG_* macros from sys/sockets.h
	[[ ${CHOST} == *-solaris* ]] && append-cflags "-D_XOPEN_SOURCE=600"

	# localstatedir for nsupdate -l, bug 395785
	tc-export BUILD_CC
	econf "${myeconfargs[@]}"

	# bug #151839
	echo '#undef SO_BSDCOMPAT' >> config.h
}

src_install() {
	default

	rm -r "${D}"/usr/bin/{arpaname,named*,nsec3hash} || die
	rm -r "${D}"/usr/{include,sbin} || die
	rm -r "${D}"/usr/share/man/man*/{arpaname,named,nsec3hash}* || die
	rm -r "${D}"/usr/share/man/man{5,8} || die
}
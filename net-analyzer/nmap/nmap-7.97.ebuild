# Distributed under the terms of the GNU General Public License v2

EAPI=7

LUA_COMPAT=( lua5-3 )
LUA_REQ_USE="deprecated"

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="sqlite,xml"

inherit autotools flag-o-matic lua-single python-single-r1 toolchain-funcs

DESCRIPTION="Network exploration tool and security / port scanner"
HOMEPAGE="https://nmap.org/"
SRC_URI="https://nmap.org/dist/nmap-7.97.tar.bz2 -> nmap-7.97.tar.bz2
"
#SRC_URI+=" https://dev.gentoo.org/~sam/distfiles/${CATEGORY}/${PN}/${PN}-7.95-patches-2.tar.xz"

LICENSE="|| ( NPSL GPL-2 )"
SLOT="0"
KEYWORDS="*"
IUSE="ipv6 libressl libssh2 ncat nping +nse ssl +system-lua"
REQUIRED_USE="system-lua? ( nse ${LUA_REQUIRED_USE} )"

RDEPEND="
	dev-libs/liblinear:=
	dev-libs/libpcre
	net-libs/libpcap
	libssh2? (
		net-libs/libssh2[zlib]
		sys-libs/zlib
	)
	nse? ( sys-libs/zlib )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	system-lua? ( ${LUA_DEPS} )
"
DEPEND="${RDEPEND}"
PATCHES=(
	"$FILESDIR"/nmap-liblua-ar.patch
   # "${WORKDIR}"/${PN}-7.95-patches-2
)


pkg_setup() {
	use system-lua && lua-single_pkg_setup
}

src_prepare() {
	rm -r liblinear/ libpcap/ libpcre/ libssh2/ libz/ || die

	cat "${FILESDIR}"/nls.m4 >> "${S}"/acinclude.m4 || die

	default

	sed -i \
		-e '/^ALL_LINGUAS =/{s|$| id|g;s|jp|ja|g}' \
		Makefile.in || die

	cp libdnet-stripped/include/config.h.in{,.nmap-orig} || die

	eautoreconf

	if [[ ${CHOST} == *-darwin* ]] ; then
		# we need the original for a Darwin-specific fix, bug #604432
		mv libdnet-stripped/include/config.h.in{.nmap-orig,} || die
	fi
}

src_configure() {
	# The bundled libdnet is incompatible with the version available in the
	# tree, so we cannot use the system library here.
	econf \
		$(use_enable ipv6) \
		$(use_with libssh2) \
		$(use_with ncat) \
		$(use_with nping) \
		$(use_with ssl openssl) \
		$(usex libssh2 --with-zlib) \
		$(usex nse --with-liblua=$(usex system-lua yes included '' '') --without-liblua) \
		$(usex nse --with-zlib) \
		--cache-file="${S}"/config.cache \
		--with-libdnet=included \
		--with-pcre=/usr \
		--without-ndiff \
		--without-zenmap
}

src_compile() {
	# Etapa 1: gera os makefile.dep normalmente
	local directory
	for directory in . libnetutil nsock/src \
		$(usex ncat ncat '') \
		$(usex nping nping '')
	do
		emake -C "${directory}" makefile.dep
	done

	# Etapa 2: força geração do config.h em libdnet-stripped
	emake -C libdnet-stripped configure

	# Etapa 3: remove a declaração bosta de strlcat do config.h gerado
	sed -i '/strlcat.*char.*/,/);/d' libdnet-stripped/include/config.h || die "remocao strlcat falhou"

	# Etapa 4: compila normalmente com AR e RANLIB definidos
	emake \
		AR=$(tc-getAR) \
		RANLIB=$(tc-getRANLIB)
}

src_install() {
	LC_ALL=C emake -j1 \
		DESTDIR="${D}" \
		STRIP=: \
		nmapdatadir="${EPREFIX}"/usr/share/nmap \
		install

	dodoc CHANGELOG HACKING docs/README docs/*.txt
}

# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools eutils prefix multilib-minimal

DESCRIPTION="A Client that groks URLs"
HOMEPAGE="https://curl.haxx.se/"
SRC_URI="https://github.com/curl/curl/releases/download/curl-8_13_0/curl-8.13.0.tar.gz -> curl-8.13.0.tar.gz"

LICENSE="curl"
SLOT="0"
KEYWORDS="*"
IUSE="adns alt-svc brotli +ftp gnutls gopher hsts +http2 idn +imap ipv6 kerberos ldap mbedtls +openssl +pop3 +progress-meter rtmp samba +smtp ssh ssl sslv3 static-libs test telnet +tftp threads zstd"
IUSE+=" curl_ssl_gnutls curl_ssl_mbedtls +curl_ssl_openssl"
IUSE+=" nghttp3 quiche"

# c-ares must be disabled for threads
# only one default ssl provider can be enabled
REQUIRED_USE="
	threads? ( !adns )
	ssl? (
		^^ (
			curl_ssl_gnutls
			curl_ssl_mbedtls
			curl_ssl_openssl
		)
	)"

#lead to lots of false negatives, bug #285669
RESTRICT="test"

RDEPEND="ldap? ( net-nds/openldap[${MULTILIB_USEDEP}] )
        brotli? ( app-arch/brotli:=[${MULTILIB_USEDEP}] )
	ssl? (
		gnutls? (
			net-libs/gnutls:0=[static-libs?,${MULTILIB_USEDEP}]
			dev-libs/nettle:0=[${MULTILIB_USEDEP}]
			app-misc/ca-certificates
		)
		mbedtls? (
			net-libs/mbedtls:0=[${MULTILIB_USEDEP}]
			app-misc/ca-certificates
		)
		openssl? (
			dev-libs/openssl:0=[sslv3(-)=,static-libs?,${MULTILIB_USEDEP}]
		)
	)
	http2? ( net-libs/nghttp2:=[${MULTILIB_USEDEP}] )
	nghttp3? (
		net-libs/nghttp3[${MULTILIB_USEDEP}]
		net-libs/ngtcp2[ssl,${MULTILIB_USEDEP}]
	)
	quiche? ( >=net-libs/quiche-0.3.0[${MULTILIB_USEDEP}] )
	idn? ( net-dns/libidn2:0=[static-libs?,${MULTILIB_USEDEP}] )
	adns? ( net-dns/c-ares:0=[${MULTILIB_USEDEP}] )
	kerberos? ( >=virtual/krb5-0-r1[${MULTILIB_USEDEP}] )
	rtmp? ( media-video/rtmpdump[${MULTILIB_USEDEP}] )
	ssh? ( net-libs/libssh2[${MULTILIB_USEDEP}] )
	sys-libs/zlib[${MULTILIB_USEDEP}]
	zstd? ( app-arch/zstd:=[${MULTILIB_USEDEP}] )"

DEPEND="${RDEPEND}"
BDEPEND="dev-lang/perl
	virtual/pkgconfig
	test? (
		sys-apps/diffutils
	)"

DOCS=( CHANGES.md README docs/{FEATURES.md,INTERNALS.md,FAQ,BUGS.md,CONTRIBUTE.md} )

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/curl/curlbuild.h
)

MULTILIB_CHOST_TOOLS=(
	/usr/bin/curl-config
)

post_src_unpack() {
	if [ ! -e "${S}" ]; then
		mv "curl-curl-" "${S}" || die
	fi
}

src_prepare() {
	default

	eprefixify curl-config.in
	eautoreconf
}

multilib_src_configure() {
	# We make use of the fact that later flags override earlier ones
	# So start with all ssl providers off until proven otherwise
	# TODO: in the future, we may want to add wolfssl (https://www.wolfssl.com/)
	local myconf=()

	myconf+=( --without-gnutls --without-mbedtls --without-ssl )
	myconf+=( --without-ca-fallback --with-ca-bundle="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt  )
	#myconf+=( --without-default-ssl-backend )
	if use ssl ; then
		if use gnutls || use curl_ssl_gnutls; then
			einfo "SSL provided by gnutls"
			myconf+=( --with-gnutls --with-nettle )
		fi
		if use mbedtls || use curl_ssl_mbedtls; then
			einfo "SSL provided by mbedtls"
			myconf+=( --with-mbedtls )
		fi
		if use openssl || use curl_ssl_openssl; then
			einfo "SSL provided by openssl"
			myconf+=( --with-ssl --with-ca-path="${EPREFIX}"/etc/ssl/certs )
		fi

		if use curl_ssl_gnutls; then
			einfo "Default SSL provided by gnutls"
			myconf+=( --with-default-ssl-backend=gnutls )
		elif use curl_ssl_mbedtls; then
			einfo "Default SSL provided by mbedtls"
			myconf+=( --with-default-ssl-backend=mbedtls )
		elif use curl_ssl_openssl; then
			einfo "Default SSL provided by openssl"
			myconf+=( --with-default-ssl-backend=openssl )
		else
			eerror "We can't be here because of REQUIRED_USE."
		fi

	else
		einfo "SSL disabled"
	fi

	# These configuration options are organized alphabetically
	# within each category.  This should make it easier if we
	# ever decide to make any of them contingent on USE flags:
	# 1) protocols first.  To see them all do
	# 'grep SUPPORT_PROTOCOLS configure.ac'
	# 2) --enable/disable options second.
	# 'grep -- --enable configure | grep Check | awk '{ print $4 }' | sort
	# 3) --with/without options third.
	# grep -- --with configure | grep Check | awk '{ print $4 }' | sort

	myconf+=(
		$(use_enable alt-svc)
		--enable-basic-auth
		--enable-bearer-auth
		--enable-digest-auth
		--enable-kerberos-auth
		--enable-negotiate-auth
		--enable-dict
		--disable-ech
		--enable-file
		$(use_enable ftp)
		$(use_enable gopher)
		$(use_enable hsts)
		--enable-http
		$(use_enable imap)
		$(use_enable ldap)
		$(use_enable ldap ldaps)
		--enable-ntlm
		$(use_enable pop3)
		--enable-rt
		--enable-rtsp
		$(use_enable samba smb)
		$(use_with ssh libssh2)
		$(use_enable smtp)
		$(use_enable telnet)
		$(use_enable tftp)
		--enable-tls-srp
		$(use_enable adns ares)
		--enable-cookies
		--enable-dateparse
		--enable-dnsshuffle
		--enable-doh
		--enable-symbol-hiding
		--enable-http-auth
		$(use_enable ipv6)
		--enable-largefile
		--enable-manual
		--enable-mime
		--enable-netrc
		$(use_enable progress-meter)
		--enable-proxy
		--disable-sspi
		$(use_enable static-libs static)
		$(use_enable threads threaded-resolver)
		$(use_enable threads pthreads)
		--disable-versioned-symbols
		--without-amissl
		--without-bearssl
		$(use_with brotli)
		--without-fish-functions-dir
		$(use_with http2 nghttp2)
		--without-hyper
		$(use_with idn libidn2)
		$(use_with kerberos gssapi "${EPREFIX}"/usr)
		--without-libgsasl
		--without-libpsl
		$(use_with nghttp3)
		$(use_with nghttp3 ngtcp2)
		$(use_with quiche)
		$(use_with rtmp librtmp)
		--without-rustls
		--without-schannel
		--without-secure-transport
		--without-winidn
		--without-wolfssl
		--with-zlib
		$(use_with zstd)
	)

	ECONF_SOURCE="${S}" \
	econf "${myconf[@]}"

	if ! multilib_is_native_abi; then
		# avoid building the client
		sed -i -e '/SUBDIRS/s:src::' Makefile || die
		sed -i -e '/SUBDIRS/s:scripts::' Makefile || die
	fi
}

multilib_src_test() {
	multilib_is_native_abi && default_src_test
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die
	rm -rf "${ED}"/etc/ || die
}
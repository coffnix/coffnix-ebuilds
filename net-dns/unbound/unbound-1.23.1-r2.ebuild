# Distributed under the terms of the GNU General Public License v2

EAPI="7"
PYTHON_COMPAT=( python3+ )

inherit autotools flag-o-matic python-single-r1 systemd user

MY_P=${PN}-${PV/_/}
DESCRIPTION="A validating, recursive and caching DNS resolver"
HOMEPAGE="https://unbound.net/ https://nlnetlabs.nl/projects/unbound/about/"
SRC_URI="https://nlnetlabs.nl/downloads/unbound/unbound-1.23.1.tar.gz -> unbound-1.23.1.tar.gz"

LICENSE="BSD GPL-2"
SLOT="0" # ABI version of libunbound.so
#SLOT="0/8"
KEYWORDS="*"
IUSE="debug dnscrypt dnstap +ecdsa ecs gost python redis +http2 selinux static-libs systemd test threads"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

CDEPEND=">=dev-libs/expat-2.1.0-r3
	>=dev-libs/libevent-2.0.21:0=
	dev-libs/openssl
	dnscrypt? ( dev-libs/libsodium )
	dnstap? (
		dev-libs/fstrm
		>=dev-libs/protobuf-c-1.0.2-r1
	)
	http2? ( net-libs/nghttp2 )
	python? ( ${PYTHON_DEPS} )
	redis? ( dev-libs/hiredis:= )"

BDEPEND="virtual/pkgconfig"

DEPEND="${CDEPEND}
	python? ( dev-lang/swig )
	systemd? ( sys-apps/systemd )"

RDEPEND="${CDEPEND}
	net-dns/dnssec-root
	selinux? ( sec-policy/selinux-bind )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.5.7-trust-anchor-file.patch
	"${FILESDIR}"/${PN}-1.6.3-pkg-config.patch
	"${FILESDIR}"/${PN}-1.10.1-find-ar.patch
)

S=${WORKDIR}/${MY_P}

pkg_setup() {
	enewgroup unbound
	enewuser unbound -1 -1 /etc/unbound unbound
	# improve security on existing installs (bug #641042)
	# as well as new installs where unbound homedir has just been created
	if [[ -d "${ROOT}/etc/unbound" ]]; then
		chown --no-dereference --from=unbound root "${ROOT}/etc/unbound"
	fi

	use python && python-single-r1_pkg_setup
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable gost) \
		$(use_enable dnscrypt) \
		$(use_enable dnstap) \
		$(use_enable ecdsa) \
		$(use_enable ecs subnet) \
		$(use_enable redis cachedb) \
		$(use_enable static-libs static) \
		$(use_enable systemd) \
		$(use_with python pythonmodule) \
		$(use_with python pyunbound) \
		$(use_with threads pthreads) \
		$(use_with http2 libnghttp2) \
		--disable-flto \
		--with-username=unbound \
		--disable-rpath \
		--enable-event-api \
		--enable-ipsecmod \
		--enable-tfo-client \
		--enable-tfo-server \
		--with-libevent="${EPREFIX%/}"/usr \
		$(usex redis --with-libhiredis="${EPREFIX%/}/usr" --without-libhiredis) \
		--with-pidfile="${EPREFIX%/}"/run/unbound.pid \
		--with-rootkey-file="${EPREFIX%/}"/etc/dnssec/root-anchors.txt \
		--with-ssl="${EPREFIX%/}"/usr \
		--with-libexpat="${EPREFIX%/}"/usr \
		--libdir=/usr/$(get_libdir)
}

src_install() {
	default
	use python && python_optimize

	newconfd "${FILESDIR}"/unbound-r1.confd unbound

	if use systemd ; then
		systemd_dounit "${FILESDIR}"/unbound.service
		systemd_dounit "${FILESDIR}"/unbound.socket
		systemd_newunit "${FILESDIR}"/unbound_at.service "unbound@.service"
		systemd_dounit "${FILESDIR}"/unbound-anchor.service
	else
		newinitd "${FILESDIR}"/unbound-r1.initd unbound
	fi

	dodoc doc/{README,CREDITS,TODO,Changelog,FEATURES,example.conf}

	# bug #315519
	dodoc contrib/unbound_munin_

	docinto selinux
	dodoc contrib/selinux/*

	exeinto /usr/share/${PN}
	doexe contrib/update-anchor.sh

	# create space for auto-trust-anchor-file...
	keepdir /etc/unbound/var

	# Used to store cache data
	keepdir /var/lib/${PN}
	fowners root:unbound /var/lib/${PN}
	fperms 0750 /var/lib/${PN}

	find "${ED}" -name '*.la' -delete || die
	if ! use static-libs ; then
		find "${ED}" -name "*.a" -delete || die
	fi
}

pkg_postinst() {
	# make var/ writable by unbound
	if [[ -d "${EROOT%/}/etc/unbound/var" ]]; then
		chown --no-dereference --from=root unbound: "${EROOT%/}/etc/unbound/var"
	fi

	einfo ""
	einfo "If you want unbound to automatically update the root-anchor file for DNSSEC validation"
	einfo "set 'auto-trust-anchor-file: ${EROOT%/}/etc/unbound/var/root-anchors.txt' in ${EROOT%/}/etc/unbound/unbound.conf"
	einfo "and run"
	einfo ""
	einfo "  su -s /bin/sh -c '${EROOT%/}/usr/sbin/unbound-anchor -a ${EROOT%/}/etc/unbound/var/root-anchors.txt' unbound"
	einfo ""
	einfo "as root to create it initially before starting unbound for the first time after enabling this."
	einfo ""
}

# vim: filetype=ebuild

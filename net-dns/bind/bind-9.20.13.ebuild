# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit python-any-r1 autotools toolchain-funcs flag-o-matic tmpfiles user

DESCRIPTION="Berkeley Internet Name Domain - Name Server"
HOMEPAGE="https://www.isc.org/software/bind"
SRC_URI="https://downloads.isc.org/isc/bind9/9.20.13/bind-9.20.13.tar.xz -> bind-9.20.13.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 GPL-2 HPND ISC MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="dnstap dnsrps doc doh fixed-rrset geoip gssapi idn lmdb selinux test urandom xml"

DEPEND="
	=net-dns/bind-tools-${PV}*
	dev-libs/jemalloc
	dev-libs/json-c:=
	dev-libs/libuv:=
	dev-libs/openssl
	sys-libs/libcap
	sys-libs/zlib
	doh? ( net-libs/nghttp2 )
	geoip? ( dev-libs/libmaxminddb )
	gssapi? ( virtual/krb5 )
	idn? ( net-dns/libidn2 )
	lmdb? ( dev-db/lmdb )
	dnstap? ( dev-libs/fstrm dev-libs/protobuf-c )
	xml? ( dev-libs/libxml2 )
"
BDEPEND="
	test? (
		${PYTHON_DEPS}
		dev-python/dnspython
		dev-python/pytest
		dev-perl/Net-DNS-SEC
		dev-util/cmocka
	)
"

RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-bind )
	sys-process/psmisc"

pkg_setup() {
	ebegin "Creating named group and user"
	enewgroup named 40
	enewuser named 40 -1 /etc/bind named
	eend ${?}
}

src_prepare() {
	default

	# should be installed by bind-tools
	sed -i -r -e "s:(nsupdate|dig|delv) ::g" bin/Makefile.in || die

	# Disable tests for now, bug 406399
	#sed -i '/^SUBDIRS/s:tests::' bin/Makefile.in lib/Makefile.in || die

	# bug #220361
	rm aclocal.m4 || die
	rm -rf libtool.m4/ || die
	eautoreconf

}

src_configure() {
	local myeconfargs=(
		AR="$(type -P $(tc-getAR))"
		--prefix="${EPREFIX}"/usr
		--sysconfdir="${EPREFIX}"/etc/bind
		--localstatedir="${EPREFIX}"/var
		--enable-full-report
		--without-readline
		--with-openssl="${ESYSROOT}"/usr
		--with-jemalloc
		--with-json-c
		--with-zlib
		$(use_enable dnstap)
		$(use_enable dnsrps)
		$(use_enable dnsrps dnsrps-dl)
		$(use_enable doh)
		$(use_enable fixed-rrset)
		$(use_enable geoip )
		$(use_with doh libnghttp2)
		$(use_with geoip maxminddb)
		$(use_with gssapi)
		$(use_with lmdb)
		$(use_with xml libxml2)
		"${@}"
	)

	export BUILD_CC=$(tc-getBUILD_CC)
	econf "${myeconfargs[@]}"

	# bug #151839
	echo '#undef SO_BSDCOMPAT' >> config.h
}

src_install() {
	default

	dodoc README.md

	if use doc; then
		docinto misc
		dodoc -r doc/misc/

		# might a 'html' useflag make sense?
		docinto html
		dodoc -r doc/arm/

		docinto contrib
		dodoc contrib/scripts/nanny.pl
	fi

	insinto /etc/bind
	newins "${FILESDIR}"/named.conf-r8 named.conf

	# ftp://ftp.rs.internic.net/domain/named.cache:
	insinto /var/bind
	newins "${FILESDIR}"/named.cache-r3 named.cache

	insinto /var/bind/pri
	newins "${FILESDIR}"/localhost.zone-r3 localhost.zone

	newinitd "${FILESDIR}"/named.init-r14 named
	newconfd "${FILESDIR}"/named.confd-r7 named

	newenvd "${FILESDIR}"/10bind.env 10bind

	# Let's get rid of those tools and their manpages since they're provided by bind-tools
	rm -f "${ED}"/usr/share/man/man1/{dig,dnssec-ksr,host,mdig,nslookup,delv,nsupdate}.1* || die
	rm -f "${ED}"/usr/share/man/man8/nsupdate.8* || die
	rm -f "${ED}"/usr/bin/{dig,delv,dnssec-ksr,host,mdig,nslookup,nsupdate} || die
	rm -f "${ED}"/usr/sbin/{dig,delv,host,mdig,nslookup,nsupdate} || die
	rm -r "${ED}"/usr/lib* || die
	for tool in cds dsfromkey importkey keyfromlabel keygen \
	revoke settime signzone verify; do
		rm -f "${ED}"/usr/{,s}bin/dnssec-"${tool}" || die
		rm -f "${ED}"/usr/share/man/man1/dnssec-"${tool}".1* || die
	done

	# bug 405251
	find "${ED}" -type f -name '*.a' -delete || die
	find "${ED}" -type f -name '*.la' -delete || die

	# bug 450406
	dosym named.cache /var/bind/root.cache

	dosym ../../var/bind/pri /etc/bind/pri
	dosym ../../var/bind/sec /etc/bind/sec
	dosym ../../var/bind/dyn /etc/bind/dyn
	keepdir /var/bind/{pri,sec,dyn} /var/log/named

	fowners root:named /{etc,var}/bind /var/log/named /var/bind/{sec,pri,dyn}
	fowners root:named /var/bind/named.cache /var/bind/pri/localhost.zone /etc/bind/named.conf
	fperms 0640 /var/bind/named.cache /var/bind/pri/localhost.zone /etc/bind/named.conf
	fperms 0750 /etc/bind /var/bind/pri
	fperms 0770 /var/log/named /var/bind/{,sec,dyn}

	dotmpfiles "${FILESDIR}"/named.conf
	exeinto /usr/libexec
	doexe "${FILESDIR}/generate-rndc-key.sh"
}

pkg_postinst() {
	tmpfiles_process named.conf

	if [[ ! -f '/etc/bind/rndc.key' && ! -f '/etc/bind/rndc.conf' ]]; then
		if use urandom ; then
			einfo "Using /dev/urandom for generating rndc.key"
			usr/sbin/rndc-confgen -r /dev/urandom -a
			echo
		else
			einfo "Using /dev/random for generating rndc.key"
			/usr/sbin/rndc-confgen -a
			echo
		fi
		chown root:named /etc/bind/rndc.key || die
		chmod 0640 /etc/bind/rndc.key || die
	fi

	einfo
	einfo "You can edit /etc/conf.d/named to customize named settings"
	einfo
	einfo "If you'd like to run bind in a chroot AND this is a new"
	einfo "install OR your bind doesn't already run in a chroot:"
	einfo "1) Uncomment and set the CHROOT variable in /etc/conf.d/named."
	einfo "2) Run \`emerge --config '=${CATEGORY}/${PF}'\`"
	einfo

	CHROOT=$(source /etc/conf.d/named 2>/dev/null; echo ${CHROOT})
	if [[ -n ${CHROOT} ]]; then
		elog "NOTE: As of net-dns/bind-9.4.3_p5-r1 the chroot part of the init-script got some major changes!"
		elog "To enable the old behaviour (without using mount) uncomment the"
		elog "CHROOT_NOMOUNT option in your /etc/conf.d/named config."
		elog "If you decide to use the new/default method, ensure to make backup"
		elog "first and merge your existing configs/zones to /etc/bind and"
		elog "/var/bind because bind will now mount the needed directories into"
		elog "the chroot dir."
	fi
}

pkg_config() {
	CHROOT=$(source /etc/conf.d/named; echo ${CHROOT})
	CHROOT_NOMOUNT=$(source /etc/conf.d/named; echo ${CHROOT_NOMOUNT})
	CHROOT_GEOIP=$(source /etc/conf.d/named; echo ${CHROOT_GEOIP})

	if [[ -z "${CHROOT}" ]]; then
		eerror "This config script is designed to automate setting up"
		eerror "a chrooted bind/named. To do so, please first uncomment"
		eerror "and set the CHROOT variable in '/etc/conf.d/named'."
		die "Unset CHROOT"
	fi
	if [[ -d "${CHROOT}" ]]; then
		ewarn "NOTE: As of net-dns/bind-9.4.3_p5-r1 the chroot part of the init-script got some major changes!"
		ewarn "To enable the old behaviour (without using mount) uncomment the"
		ewarn "CHROOT_NOMOUNT option in your /etc/conf.d/named config."
		ewarn
		ewarn "${CHROOT} already exists... some things might become overridden"
		ewarn "press CTRL+C if you don't want to continue"
		sleep 10
	fi

	echo; einfo "Setting up the chroot directory..."

	mkdir -m 0750 -p ${CHROOT} || die
	mkdir -m 0755 -p ${CHROOT}/{dev,etc,var/log,run} || die
	mkdir -m 0750 -p ${CHROOT}/etc/bind || die
	mkdir -m 0770 -p ${CHROOT}/var/{bind,log/named} ${CHROOT}/run/named/ || die

	chown root:named \
		${CHROOT} \
		${CHROOT}/var/{bind,log/named} \
		${CHROOT}/run/named/ \
		${CHROOT}/etc/bind \
		|| die

	mknod ${CHROOT}/dev/null c 1 3 || die
	chmod 0666 ${CHROOT}/dev/null || die

	mknod ${CHROOT}/dev/zero c 1 5 || die
	chmod 0666 ${CHROOT}/dev/zero || die

	if use urandom; then
		mknod ${CHROOT}/dev/urandom c 1 9 || die
		chmod 0666 ${CHROOT}/dev/urandom || die
	else
		mknod ${CHROOT}/dev/random c 1 8 || die
		chmod 0666 ${CHROOT}/dev/random || die
	fi

	if [ "${CHROOT_NOMOUNT:-0}" -ne 0 ]; then
		cp -a /etc/bind ${CHROOT}/etc/ || die
		cp -a /var/bind ${CHROOT}/var/ || die
	fi

	if [ "${CHROOT_GEOIP:-0}" -eq 1 ]; then
		if use geoip; then
			mkdir -m 0755 -p ${CHROOT}/usr/share/GeoIP || die
		fi
	fi

	elog "You may need to add the following line to your syslog-ng.conf:"
	elog "source jail { unix-stream(\"${CHROOT}/dev/log\"); };"
}

# vim: filetype=ebuild

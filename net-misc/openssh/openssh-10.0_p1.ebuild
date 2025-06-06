# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user flag-o-matic multilib autotools pam systemd toolchain-funcs

# Make it more portable between straight releases
# and _p? releases.
PARCH=${P/_}

DESCRIPTION="Port of OpenBSD's free SSH release"
HOMEPAGE="https://www.openssh.com/"
#SRC_URI="https://github.com/openssh/openssh-portable/tarball/d76b2675116617394cd355a3437b4963a562b64d -> openssh-portable-9.9_p2-d76b267.tar.gz"
#S="${WORKDIR}/openssh-openssh-portable-d76b267"

SRC_URI="https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.0p2.tar.gz"
S="${WORKDIR}/openssh-10.0p1"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="*"
# Probably want to drop ssl defaulting to on in a future version.
IUSE="abi_mips_n32 audit bindist debug hpn kerberos kernel_linux ldns libedit livecd pam +pie +scp security-key sctp selinux +ssl static test X xmss"

RESTRICT="!test? ( test )"

REQUIRED_USE="
	ldns? ( ssl )
	pie? ( !static )
	static? ( !kerberos !pam )
	xmss? ( ssl )
	test? ( ssl )
"
LIB_DEPEND="
	audit? ( sys-process/audit[static-libs(+)] )
	ldns? ( net-libs/ldns[ecdsa(+),ssl(+)] )
	libedit? ( dev-libs/libedit:=[static-libs(+)] )
	security-key? ( >=dev-libs/libfido2-1.5.0:=[static-libs(+)] )
	selinux? ( >=sys-libs/libselinux-1.28[static-libs(+)] )
	ssl? ( >=dev-libs/openssl-1.1.1l:0=[static-libs(+)] )
	>=sys-libs/zlib-1.2.3:=[static-libs(+)]
"
RDEPEND="
	!static? ( ${LIB_DEPEND//\[static-libs(+)]} )
	pam? ( sys-libs/pam )
	kerberos? ( virtual/krb5 )
"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	static? ( ${LIB_DEPEND} )
"
RDEPEND="${RDEPEND}
	pam? ( >=sys-auth/pambase-20081028 )
	!prefix? ( sys-apps/shadow )
	X? ( x11-apps/xauth )
"
BDEPEND="
	virtual/pkgconfig
	sys-devel/autoconf
"

src_prepare() {
	sed -i \
		-e "/_PATH_XAUTH/s:/usr/X11R6/bin/xauth:${EPREFIX}/usr/bin/xauth:" \
		pathnames.h || die

	# don't break .ssh/authorized_keys2 for fun
	sed -i '/^AuthorizedKeysFile/s:^:#:' sshd_config || die

	[[ -d ${WORKDIR}/patches ]] && eapply "${WORKDIR}"/patches

	eapply_user #473004

	# These tests are currently incompatible with PORTAGE_TMPDIR/sandbox
	sed -e '/\t\tpercent \\/ d' \
		-i regress/Makefile || die

	tc-export PKG_CONFIG
	local sed_args=(
		-e "s:-lcrypto:$(${PKG_CONFIG} --libs openssl):"
		# Disable fortify flags ... our gcc does this for us
		-e 's:-D_FORTIFY_SOURCE=2::'
	)

	eautoreconf
}

src_configure() {
	addwrite /dev/ptmx

	use debug && append-cppflags -DSANDBOX_SECCOMP_FILTER_DEBUG
	use static && append-ldflags -static
	use xmss && append-cflags -DWITH_XMSS

	local myconf=(
		--with-ldflags="${LDFLAGS}"
		--disable-strip
		--with-pid-dir="${EPREFIX}"$(usex kernel_linux '' '/var')/run
		--sysconfdir="${EPREFIX}"/etc/ssh
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/misc
		--datadir="${EPREFIX}"/usr/share/openssh
		--with-privsep-path="${EPREFIX}"/var/empty
		--with-privsep-user=sshd
		--with-hardening
		--without-zlib-version-check  # FL-11529
		$(use_with audit audit linux)
		$(use_with kerberos kerberos5 "${EPREFIX}"/usr)
		$(use sctp && use_with sctp)
		$(use_with ldns)
		$(use_with libedit)
		$(use_with pam)
		$(use_with pie)
		$(use_with selinux)
		$(use_with ssl openssl)
		$(use_with ssl ssl-engine)
	)

	if use elibc_musl; then
		# musl defines bogus values for UTMP_FILE and WTMP_FILE
		# https://bugs.gentoo.org/753230
		myconf+=( --disable-utmp --disable-wtmp )
	fi

	# Workaround for Clang 15 miscompilation with -fzero-call-used-regs=all
	# bug #869839 (https://github.com/llvm/llvm-project/issues/57692)
	tc-is-clang && myconf+=( --without-hardening )

	econf "${myconf[@]}"
}

src_test() {
	local t skipped=() failed=() passed=()
	local tests=( interop-tests compat-tests )

	local tests=( compat-tests )
	local shell=$(egetshell "${UID}")
	if [[ ${shell} == */nologin ]] || [[ ${shell} == */false ]] ; then
		ewarn "Running the full OpenSSH testsuite requires a usable shell for the 'portage'"
		ewarn "user, so we will run a subset only."
		tests+=( interop_tests )
	else
	    tests+=( tests )
	fi
	local -x SUDO= SSH_SK_PROVIDER= TEST_SSH_UNSAFE_PERMISSIONS=1
	mkdir -p "${HOME}"/.ssh || die
	emake -j1 "${tests[@]}" </dev/null
}

# Gentoo tweaks to default config files.
tweak_ssh_configs() {
	local locale_vars=(
		# These are language variables that POSIX defines.
		# http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html#tag_08_02
		LANG LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES LC_MONETARY LC_NUMERIC LC_TIME

		# These are the GNU extensions.
		# https://www.gnu.org/software/autoconf/manual/html_node/Special-Shell-Variables.html
		LANGUAGE LC_ADDRESS LC_IDENTIFICATION LC_MEASUREMENT LC_NAME LC_PAPER LC_TELEPHONE
	)

	# First the server config.
	cat <<-EOF >> "${ED}"/etc/ssh/sshd_config

	# Allow client to pass locale environment variables. #367017
	AcceptEnv ${locale_vars[*]}

	# Allow client to pass COLORTERM to match TERM. #658540
	AcceptEnv COLORTERM
	EOF

	# Then the client config.
	cat <<-EOF >> "${ED}"/etc/ssh/ssh_config

	# Send locale environment variables. #367017
	SendEnv ${locale_vars[*]}

	# Send COLORTERM to match TERM. #658540
	SendEnv COLORTERM
	EOF

	if use pam ; then
		sed -i \
			-e "/^#UsePAM /s:.*:UsePAM yes:" \
			-e "/^#PasswordAuthentication /s:.*:PasswordAuthentication no:" \
			-e "/^#PrintMotd /s:.*:PrintMotd no:" \
			-e "/^#PrintLastLog /s:.*:PrintLastLog no:" \
			"${ED}"/etc/ssh/sshd_config || die
	fi

	if use livecd ; then
		sed -i \
			-e '/^#PermitRootLogin/c# Allow root login with password on livecds.\nPermitRootLogin Yes' \
			"${ED}"/etc/ssh/sshd_config || die
	fi
}

src_install() {
	emake install-nokeys DESTDIR="${D}"
	fperms 600 /etc/ssh/sshd_config
	dobin contrib/ssh-copy-id
	newinitd "${FILESDIR}"/sshd-r1.initd sshd
	newconfd "${FILESDIR}"/sshd-r1.confd sshd

	if use pam; then
		newpamd "${FILESDIR}"/sshd.pam_include.2 sshd
	fi

	tweak_ssh_configs

	doman contrib/ssh-copy-id.1
	dodoc CREDITS OVERVIEW README* TODO sshd_config

	diropts -m 0700
	dodir /etc/skel/.ssh

	rmdir "${ED}"/var/empty || die
}

pkg_preinst() {
	if ! use ssl && has_version "${CATEGORY}/${PN}[ssl]"; then
		show_ssl_warning=1
	fi
	enewgroup sshd 22
	enewuser sshd 22 -1 /var/empty sshd
}

pkg_postinst() {
	# OpenSSH is a critical service and restarting the daemon may be required for proper operation.
	# This was needed with the glibc-2.33 update.

	if [ -n "$( rc-service sshd status| grep started )" ]; then
		einfo "Restarting sshd service."
		/etc/init.d/sshd restart
	fi
}

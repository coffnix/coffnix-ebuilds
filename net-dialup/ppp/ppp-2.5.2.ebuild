# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit linux-info pam toolchain-funcs

DESCRIPTION="Point-to-Point Protocol (PPP)"
HOMEPAGE="https://ppp.samba.org/"
SRC_URI="https://github.com/ppp-project/ppp/tarball/0d9fdafb7f743abfad7e308709ac917fef658c14 -> ppp-2.5.2-0d9fdaf.tar.gz"
LICENSE="BSD GPL-2"

S="${WORKDIR}/ppp-project-ppp-0d9fdaf"

SLOT="0/${PV}"
KEYWORDS="*"
IUSE="activefilter atm pam selinux systemd ipv6"

DEPEND="
	dev-libs/openssl:0=
	sys-libs/libxcrypt
	activefilter? ( net-libs/libpcap )
	atm? ( net-dialup/linux-atm )
	pam? ( sys-libs/pam )
	systemd? ( sys-apps/systemd )
"
RDEPEND="
	${DEPEND}
	selinux? ( sec-policy/selinux-ppp )
"
BDEPEND="virtual/pkgconfig"
PDEPEND="net-dialup/ppp-scripts"

pkg_setup() {
	local CONFIG_CHECK="~PPP ~PPP_ASYNC ~PPP_SYNC_TTY"
	local ERROR_PPP="CONFIG_PPP:\t missing PPP support (REQUIRED)"
	local ERROR_PPP_ASYNC="CONFIG_PPP_ASYNC:\t missing asynchronous serial line discipline"
	ERROR_PPP_ASYNC+=" (optional, but highly recommended)"
	local WARNING_PPP_SYNC_TTY="CONFIG_PPP_SYNC_TTY:\t missing synchronous serial line discipline"
	WARNING_PPP_SYNC_TTY+=" (optional; used by 'sync' pppd option)"
	if use activefilter ; then
		CONFIG_CHECK+=" ~PPP_FILTER"
		local ERROR_PPP_FILTER="CONFIG_PPP_FILTER:\t missing PPP filtering support (REQUIRED)"
	fi
	CONFIG_CHECK+=" ~PPP_DEFLATE ~PPP_BSDCOMP ~PPP_MPPE"
	local ERROR_PPP_DEFLATE="CONFIG_PPP_DEFLATE:\t missing Deflate compression (optional, but highly recommended)"
	local ERROR_PPP_BSDCOMP="CONFIG_PPP_BSDCOMP:\t missing BSD-Compress compression (optional, but highly recommended)"
	local WARNING_PPP_MPPE="CONFIG_PPP_MPPE:\t missing MPPE encryption (optional, mostly used by PPTP links)"
	CONFIG_CHECK+=" ~PPPOE ~PACKET"
	local WARNING_PPPOE="CONFIG_PPPOE:\t missing PPPoE support (optional, needed by pppoe plugin)"
	local WARNING_PACKET="CONFIG_PACKET:\t missing AF_PACKET support (optional, used by pppoe plugin)"
	if use atm ; then
		CONFIG_CHECK+=" ~PPPOATM"
		local WARNING_PPPOATM="CONFIG_PPPOATM:\t missing PPPoA support (optional, needed by pppoatm plugin)"
	fi

	linux-info_pkg_setup
}

src_prepare() {
	default

	# Set the right paths in radiusclient.conf
	sed -e "s:/usr/local/etc:/etc:" \
		-e "s:/usr/local/sbin:/usr/sbin:" \
		-i pppd/plugins/radius/etc/radiusclient.conf || die
	# Set config dir to /etc/ppp/radius
	sed -i -e "s:/etc/radiusclient:/etc/ppp/radius:g" \
		pppd/plugins/radius/{*.8,*.c,*.h} \
		pppd/plugins/radius/etc/* || die

	./autogen.sh
}

src_configure() {
	# https://bugs.gentoo.org/943931
	append-cflags -std=gnu17

	local args=(
		--localstatedir="${EPREFIX}"/var
		--runstatedir="${EPREFIX}"/run
		$(use_enable systemd)
		$(use_with atm)
		$(use_with pam)
		$(use_with activefilter pcap)
		--enable-cbcp
		--enable-multilink
	)
	econf "${args[@]}"
}

src_install() {
	default

	find "${ED}" -name '*.la' -type f -delete || die

	if use pam; then
		pamd_mimic_system ppp auth account session
	fi

	insinto /etc/modprobe.d
	newins "${FILESDIR}/modules.ppp" ppp.conf

	dosbin scripts/p{on,off,log}
	doman scripts/pon.1
	dosym pon.1 /usr/share/man/man1/poff.1
	dosym pon.1 /usr/share/man/man1/plog.1

	# Adding misc. specialized scripts to doc dir
	dodoc -r scripts

	newtmpfiles "${FILESDIR}/pppd.tmpfiles-r1" pppd.conf

	insinto /etc/ppp/radius
	doins pppd/plugins/radius/etc/{dictionary*,issue,port-id-map,radiusclient.conf,realms,servers}
}

pkg_postinst() {
	tmpfiles_process pppd.conf
}
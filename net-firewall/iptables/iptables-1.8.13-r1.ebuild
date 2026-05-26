# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
COMMON_DEPEND="
  conntrack? ( net-libs/libnetfilter_conntrack )
  netlink? ( net-libs/libnfnetlink )
  nftables? (
    net-libs/libmnl:=
    net-libs/libnftnl:=
  )
  pcap? ( net-libs/libpcap )
"

DESCRIPTION="Linux kernel (2.4+) firewall, NAT and packet mangling tools"
HOMEPAGE="https://www.netfilter.org/projects/iptables/"
SRC_URI="https://www.netfilter.org/pub/iptables/iptables-1.8.13.tar.xz -> iptables-1.8.13.tar.xz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="conntrack ipv6 netlink nftables pcap static-libs"
BDEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	nftables? (
	  sys-devel/flex
	  virtual/yacc
	)
"
RDEPEND="${COMMON_DEPEND}
	nftables? ( net-misc/ethertypes )
"
DEPEND="${COMMON_DEPEND}
	sys-kernel/linux-headers
	virtual/os-headers
"
src_prepare() {
	# use the saner headers from the kernel
	rm include/linux/{kernel,types}.h || die
	 # Only run autotools if user patched something
	eapply_user && eautoreconf || elibtoolize
}

src_configure() {
	# Some libs use $(AR) rather than libtool to build #444282
	tc-export AR
	 # Hack around struct mismatches between userland & kernel for some ABIs. #472388
	use amd64 && [[ ${ABI} == "x32" ]] && append-flags -fpack-struct
	 sed -i \
	  -e "/nfnetlink=[01]/s:=[01]:=$(usex netlink 1 0):" \
	  -e "/nfconntrack=[01]/s:=[01]:=$(usex conntrack 1 0):" \
	  configure || die
	 local myeconfargs=(
	  --sbindir="${EPREFIX}/sbin" # W: The = here is literal. To assign by index, use ( [index]=value ) with n…
	  --libexecdir="${EPREFIX}/$(get_libdir)" # W: The = here is literal. To assign by index, use ( [index]=va…
	  --enable-devel
	  --enable-shared
	  $(use_enable nftables) # W: Prefer mapfile or read -a to split command output (or quote to avoid splitti…
	  $(use_enable pcap bpf-compiler) # W: Prefer mapfile or read -a to split command output (or quote to avoi…
	  $(use_enable pcap nfsynproxy) # W: Prefer mapfile or read -a to split command output (or quote to avoid …
	  $(use_enable static-libs static) # W: Prefer mapfile or read -a to split command output (or quote to avo…
	  $(use_enable ipv6) # W: Prefer mapfile or read -a to split command output (or quote to avoid splitting).
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	emake V=1
}

src_install() {
	default
	dodoc iptables/iptables.xslt
	 into /
	dosbin iptables/iptables-apply
	dosym iptables-apply /sbin/ip6tables-apply
	doman iptables/iptables-apply.8
	 insinto /usr/include
	doins include/iptables.h $(use ipv6 && echo include/ip6tables.h) # W: Quote this to prevent word splitting.
	insinto /usr/include/iptables
	doins include/iptables/internal.h
	 keepdir /var/lib/iptables
	newinitd "${FILESDIR}"/${PN}-r2.init iptables
	newconfd "${FILESDIR}"/${PN}-r1.confd iptables
	 if use ipv6 ; then
	  keepdir /var/lib/ip6tables
	  dosym iptables /etc/init.d/ip6tables
	  newconfd "${FILESDIR}"/ip6tables-r1.confd ip6tables
	fi
	 rm -f "${ED}"/sbin/iptables
	rm -f "${ED}"/sbin/ip6tables
	rm -f "${ED}"/sbin/iptables-save
	rm -f "${ED}"/sbin/iptables-restore
	rm -f "${ED}"/sbin/ip6tables-save
	rm -f "${ED}"/sbin/ip6tables-restore
	 if use nftables; then
	  rm "${ED}"/etc/ethertypes || die
	  rm "${ED}"/sbin/{arptables,ebtables}{,-{save,restore}} || die
	   dosym xtables-nft-multi /sbin/iptables
	  dosym xtables-nft-multi /sbin/ip6tables
	  dosym xtables-nft-multi /sbin/iptables-save
	  dosym xtables-nft-multi /sbin/iptables-restore
	  dosym xtables-nft-multi /sbin/ip6tables-save
	  dosym xtables-nft-multi /sbin/ip6tables-restore
	else
	  dosym xtables-legacy-multi /sbin/iptables
	  dosym xtables-legacy-multi /sbin/ip6tables
	  dosym xtables-legacy-multi /sbin/iptables-save
	  dosym xtables-legacy-multi /sbin/iptables-restore
	  dosym xtables-legacy-multi /sbin/ip6tables-save
	  dosym xtables-legacy-multi /sbin/ip6tables-restore
	fi
	 find "${ED}" -type f -name "*.la" -delete || die
}

# vim: filetype=ebuild

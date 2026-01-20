# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit flag-o-matic readme.gentoo-r1 user

DESCRIPTION="Anonymizing overlay network for TCP"
HOMEPAGE="https://torproject.org"
SRC_URI="https://dist.torproject.org/tor-${PV}.tar.gz -> tor-${PV}.tar.gz"
LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="*"
DOCS=(
	README.md
	ChangeLog
	ReleaseNotes
	doc/HACKING
)
IUSE="caps lzma seccomp selinux tor-hardening zstd"
RDEPEND="dev-libs/libevent[ssl]
	sys-libs/zlib
	caps? ( sys-libs/libcap )
	dev-libs/openssl
	lzma? ( app-arch/xz-utils )
	seccomp? ( sys-libs/libseccomp )
	zstd? ( app-arch/zstd )
	
"
DEPEND="${RDEPEND}
	app-text/asciidoc
	
"
pkg_setup() {
	enewgroup tor
	enewuser tor -1 -1 /var/lib/tor tor
}
src_configure() {
	export ac_cv_lib_cap_cap_init=$(usex caps)
	econf \
	  --localstatedir="${EPREFIX}/var" \
	  --enable-system-torrc \
	  --enable-asciidoc \
	  --disable-android \
	  --disable-libfuzzer \
	  --disable-module-dirauth \
	  --enable-pic \
	  --disable-rust \
	  --disable-restart-debugging \
	  --disable-zstd-advanced-apis  \
	  --disable-unittests \
	  --disable-coverage \
	  --disable-libscrypt \
	  $(use_enable lzma) \
	  $(use_enable seccomp) \
	  $(use_enable tor-hardening gcc-hardening) \
	  $(use_enable tor-hardening linker-hardening) \
	  $(use_enable zstd)
}
src_install() {
	default
	readme.gentoo_create_doc
	 newconfd "${FILESDIR}"/tor.confd tor
	newinitd "${FILESDIR}"/tor.initd-r8 tor
	 keepdir /var/lib/tor
	 fperms 750 /var/lib/tor
	fowners tor:tor /var/lib/tor
	 insinto /etc/tor/
	newins "${FILESDIR}"/torrc-r1 torrc
}


# vim: filetype=ebuild

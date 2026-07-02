# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools readme.gentoo-r1 systemd user

DESCRIPTION="Client Server backup system"
HOMEPAGE="https://www.urbackup.org/"
SRC_URI="https://hndl.urbackup.org/Server/${PV}/${P}.tar.gz"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="crypt curl debug hardened fuse zlib"

RDEPEND="app-arch/zstd:0=
	dev-db/lmdb:0=
	dev-db/sqlite:3
	dev-lang/lua
	crypt? ( dev-libs/crypto++:0= )
	curl? ( net-misc/curl )
	fuse? ( sys-fs/fuse:0 )
	zlib? ( sys-libs/zlib:0= )"

DOC_CONTENTS="You may need to open the following ports in firewall:\\n
55413/tcp, 55414/tcp, 55415/tcp, 35623/udp
Default web-gui URL is http://localhost:55414/\\n\\n"

pkg_setup() {
	enewgroup urbackup
	enewuser urbackup -1 -1 /var/lib/urbackup urbackup -s /sbin/nologin
}

src_prepare() {
	default

	# Disable client autoupdate
	sed -i  -e '/download_client/s/true/false/' \
		-e '/autoupdate_clients/s/true/false/' \
		urbackupserver/server_settings.cpp \
		|| die "sed failed for server_settings.cpp"
	# Remove key for client autoupdate and license
	sed -i  -e '/\/urbackup\/urbackup_ecdsa409k1.pub/d' \
		-e 's|urbackupserver/urbackup_ecdsa409k1.pub ||' \
		-e '/\/server-license.txt/d' \
		-e 's|server-license.txt ||' \
		Makefile.am || die "sed failed for Makefile.am"

	eautoreconf
}

src_configure() {
	econf --enable-packaging \
		--disable-embedded-cryptopp \
		--without-embedded-lmdb \
		--without-embedded-lua \
		--without-embedded-sqlite3 \
		--disable-embedded-zstd \
		"$(use_enable debug assertions)" \
		"$(use_enable hardened fortify)" \
		"$(use_with crypt crypto)" \
		"$(use_with curl mail)" \
		"$(use_with fuse mountvhd)" \
		"$(use_with zlib)"
}

src_install() {
	default

	doman docs/urbackupsrv.1

	keepdir /var/lib/urbackup
	fowners urbackup:urbackup /var/lib/urbackup

	insinto /etc/logrotate.d
	newins logrotate_urbackupsrv urbackup-server

	newinitd "${FILESDIR}"/urbackup-server.initd urbackup-server
	newconfd "${FILESDIR}"/urbackup-server.confd urbackup-server
	systemd_dounit "${FILESDIR}"/urbackup-server.service

	insinto /etc/urbackup
	doins "${FILESDIR}"/urbackup-server

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7

PLOCALES="cs da de es fa fr it nl pl pt_BR ru sk uk zh_CN zh_TW"
PLOCALE_BACKUP="en"
WX_GTK_VER="3.2-gtk3"

inherit plocale systemd wxwidgets user

DESCRIPTION="Client Server backup system"
HOMEPAGE="https://www.urbackup.org/"
SRC_URI="https://hndl.urbackup.org/Client/${PV}/${P}.tar.gz"
S="${WORKDIR}/${P}.0"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="debug hardened nls X zlib zstd"

RDEPEND="app-arch/zstd:=
	dev-db/sqlite:3
	dev-libs/crypto++:0=
	dev-libs/icu:0=
	sys-libs/zlib:0=
	X? ( x11-libs/wxGTK:${WX_GTK_VER}[X] )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig
	nls? ( sys-devel/gettext )"

PATCHES=( "${FILESDIR}/${PN}"-2.5.25-gcc13.patch )

pkg_setup() {
	enewgroup urbackup
	enewuser urbackup -1 -1 /var/lib/urbackup urbackup -s /sbin/nologin
}

src_configure() {
	econf --disable-clientupdate \
		--without-embedded-sqlite3 \
		"$(use_enable debug assertions)" \
		"$(use_enable hardened fortify)" \
		"$(use_enable !X headless)" \
		"$(use_with zlib)" \
		"$(use_with zstd)"
	use X && setup-wxwidgets
}

src_install() {
	default

	doman docs/urbackupclientbackend.1

	keepdir /var/lib/urbackup/data
	fowners urbackup:urbackup /var/lib/urbackup /var/lib/urbackup/data

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/urbackup-client.logrotate urbackup-client

	newinitd "${FILESDIR}"/urbackup-client.initd urbackup-client
	newconfd "${FILESDIR}"/urbackup-client.confd urbackup-client
	systemd_dounit "${FILESDIR}"/urbackup-client.service

	insinto /etc/urbackup
	doins "${FILESDIR}"/urbackup-client
}

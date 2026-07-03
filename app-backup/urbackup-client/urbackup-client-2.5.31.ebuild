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
IUSE="debug hardened nls X zlib +zstd"

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
	enewuser urbackup -1 -1 /var/lib/urbackup urbackup
}

# compat with old sqlite 3.50.0, remove this after update sqlite
src_prepare() {
	default

	sed -i \
		-e 's/sqlite3_db_status64(db, SQLITE_DBSTATUS_TEMPBUF_SPILL, &iCur64, &iHiwtr64,/sqlite3_db_status(db, SQLITE_DBSTATUS_TEMPBUF_SPILL, (int *)\&iCur64, (int *)\&iHiwtr64,/' \
		-e 's/sqlite3_str_free(\([^)]*\));/sqlite3_free(sqlite3_str_finish(\1));/g' \
		-e 's/sqlite3_str_truncate(pOut, iStartLen+ii);/{ char *zTmp = sqlite3_str_finish(pOut); pOut = sqlite3_str_new(0); sqlite3_str_append(pOut, zTmp, iStartLen+ii); sqlite3_free(zTmp); }/g' \
		-e 's/sqlite3_str_truncate(pOut, nByte);/{ char *zTmp = sqlite3_str_finish(pOut); pOut = sqlite3_str_new(0); sqlite3_str_append(pOut, zTmp, nByte); sqlite3_free(zTmp); }/g' \
		sqlite/shell.c || die
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

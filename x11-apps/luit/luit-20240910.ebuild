# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xorg-3

DESCRIPTION="Locale and ISO 2022 support for Unicode terminals"

KEYWORDS="*"
IUSE=""
RDEPEND="sys-libs/zlib
	x11-libs/libX11
	x11-libs/libfontenc"
DEPEND="${RDEPEND}"
SRC_URI="https://invisible-mirror.net/archives/${PN}/${P}.tgz"

src_configure() {
	econf --disable-fontenc --enable-iconv
}

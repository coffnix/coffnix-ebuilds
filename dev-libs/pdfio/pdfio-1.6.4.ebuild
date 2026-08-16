EAPI=7

DESCRIPTION="PDF read/write library"
HOMEPAGE="https://github.com/michaelrsweet/pdfio"
SRC_URI="https://github.com/michaelrsweet/pdfio/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="png static-libs"

DEPEND="
	sys-libs/zlib
	png? ( media-libs/libpng )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/pdfio-${PV}"

src_configure() {
	local myeconfargs=(
		--enable-shared
		$(use_enable static-libs static)
		$(use_enable png libpng)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install
}

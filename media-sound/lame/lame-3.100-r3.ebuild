# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="https://lame.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="debug cpu_flags_x86_mmx +frontend mp3rtp sndfile static-libs"

RDEPEND="
	frontend? (
		>=sys-libs/ncurses-5.7-r7:0=
		sndfile? ( >=media-libs/libsndfile-1.0.2 )
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/gettext
	>=sys-devel/gettext-0.26
	virtual/pkgconfig
	cpu_flags_x86_mmx? ( dev-lang/nasm )
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.96-ccc.patch
	"${FILESDIR}"/${PN}-3.98-gtk-path.patch
	"${FILESDIR}"/${PN}-3.99.5-tinfo.patch
	"${FILESDIR}"/${PN}-3.99.5-msse.patch
	"${FILESDIR}"/${PN}-3.100-symbols.patch
	"${FILESDIR}"/${PN}-3.100-pkgconfig.patch
)

src_prepare() {
	default

	mkdir -p libmp3lame/i386/.libs || die
	sed -i -e '/define sp/s/+/ + /g' libmp3lame/i386/nasm.h || die
	use cpu_flags_x86_mmx || sed -i -e '/AC_PATH_PROG/s:nasm:dIsAbLe&:' configure.in || die

	mv configure.{in,ac} || die

	# gettext 0.26
	export WANT_AUTOCONF=2.72
	AT_M4DIR="/usr/share/gettext/m4 ." eautoreconf
}

src_configure() {
	local myconf=(
		--disable-mp3x
		--enable-dynamic-frontends
		$(use_enable frontend)
		$(use_enable mp3rtp)
		$(usex sndfile '--with-fileio=sndfile' '')
		$(use_enable debug debug norm)
		$(use_enable static-libs static)
		$(usex cpu_flags_x86_mmx '--enable-nasm' '')
	)
	econf "${myconf[@]}"
}

src_install() {
	emake DESTDIR="${D}" pkghtmldir="${EPREFIX}/usr/share/doc/${PF}/html" install

	dodoc API ChangeLog HACKING README STYLEGUIDE TODO USAGE
	docinto html
	dodoc misc/lameGUI.html Dll/LameDLLInterface.htm

	find "${ED}" -name '*.la' -type f -delete || die
}

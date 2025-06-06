# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal toolchain-funcs

DESCRIPTION="Version 2 of an advanced replacement library for libraries like libXpm"
HOMEPAGE="https://www.enlightenment.org/
	https://sourceforge.net/projects/enlightenment/files/imlib2-src/"
SRC_URI="https://downloads.sourceforge.net/enlightenment/imlib2-1.12.5.tar.xz -> imlib2-1.12.5.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="bzip2 debug doc +gif heif +jpeg lzma mp3 +png postscript +shm static-libs svg
	+tiff +truetype +webp +X zlib
	cpu_flags_x86_mmx cpu_flags_x86_sse2"

REQUIRED_USE="shm? ( X )"

RDEPEND="
	media-libs/freetype:2[${MULTILIB_USEDEP}]
	bzip2? ( app-arch/bzip2[${MULTILIB_USEDEP}] )
	gif? ( media-libs/giflib:=[${MULTILIB_USEDEP}] )
	heif? ( media-libs/libheif:=[${MULTILIB_USEDEP}] )
	jpeg? ( virtual/jpeg:0=[${MULTILIB_USEDEP}] )
	lzma? ( app-arch/xz-utils[${MULTILIB_USEDEP}] )
	mp3? ( media-libs/libid3tag:=[${MULTILIB_USEDEP}] )
	png? ( >=media-libs/libpng-1.6.10:0=[${MULTILIB_USEDEP}] )
	postscript? ( app-text/libspectre[${MULTILIB_USEDEP}] )
	svg? ( gnome-base/librsvg:=[${MULTILIB_USEDEP}] )
	tiff? ( >=media-libs/tiff-4.0.4:0[${MULTILIB_USEDEP}] )
	webp? ( media-libs/libwebp:=[${MULTILIB_USEDEP}] )
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
	)
	zlib? ( sys-libs/zlib[${MULTILIB_USEDEP}] )
	!<media-plugins/imlib2_loaders-1.7.0
"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"
BDEPEND="virtual/pkgconfig"

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable debug)
		$(use_enable static-libs static)
		$(use_enable truetype text)
		$(use_with bzip2 bz2)
		$(use_with gif)
		$(use_with heif)
		$(use_with jpeg)
		$(use_with lzma)
		$(use_with mp3 id3)
		$(use_with png)
		$(use_with postscript ps)
		$(use_with shm x-shm-fd)
		$(use_with svg)
		$(use_with tiff)
		$(use_with webp)
		$(use_with X x)
		$(use_with zlib)
	)

	# imlib2 has different configure options for x86/amd64 assembly
	if [[ $(tc-arch) == amd64 ]]; then
		myeconfargs+=( $(use_enable cpu_flags_x86_sse2 amd64) --disable-mmx )
	else
		myeconfargs+=( --disable-amd64 $(use_enable cpu_flags_x86_mmx mmx) )
	fi

	ECONF_SOURCE="${S}" \
	econf "${myeconfargs[@]}"
}

multilib_src_install() {
	V=1 emake install DESTDIR="${D}"
	find "${D}" -name '*.la' -delete || die
}

multilib_src_install_all() {
	if use doc; then
		local HTML_DOCS=( "${S}"/doc/. )
		rm "${S}"/doc/Makefile.{am,in} || die
	fi
	einstalldocs
}
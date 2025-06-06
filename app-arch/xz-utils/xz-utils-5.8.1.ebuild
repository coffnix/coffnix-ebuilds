# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit libtool preserve-libs usr-ldscript
MY_P="${PN/-utils}-${PV/_}"
SRC_URI="https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.gz -> xz-5.8.1.tar.gz"
KEYWORDS="*"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="utils for managing LZMA compressed files"
HOMEPAGE="https://tukaani.org/xz/"

# See top-level COPYING file as it outlines the various pieces and their licenses.
LICENSE="public-domain LGPL-2.1+ GPL-2+"
SLOT="0"
IUSE="elibc_FreeBSD +extra-filters nls static-libs"

RDEPEND="!<app-arch/lzma-4.63
	!<app-arch/p7zip-4.57
	!<app-i18n/man-pages-de-2.16"
DEPEND="${RDEPEND}"

# Tests currently do not account for smaller feature set
RESTRICT="!extra-filters? ( test )"

src_prepare() {
	default
	elibtoolize
}

src_configure() {
	local myconf=(
		--enable-threads
		$(use_enable nls)
		$(use_enable static-libs static)
	)
	if ! use extra-filters; then
		myconf+=(
			# LZMA1 + LZMA2 for standard .lzma & .xz files
			--enable-encoders=lzma1,lzma2
			--enable-decoders=lzma1,lzma2
			# those are used by default, depending on preset
			--enable-match-finders=hc3,hc4,bt4
			# CRC64 is used by default, though some (old?) files use CRC32
			--enable-checks=crc32,crc64
		)
	fi
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_install() {
	default
	gen_usr_ldscript -a lzma
	find "${ED}" -type f -name '*.la' -delete || die
	rm "${ED}"/usr/share/doc/${PF}/COPYING* || die
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/liblzma$(get_libname 0)
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/liblzma$(get_libname 0)
}
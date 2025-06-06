# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="https://www.gnu.org/software/gzip/"
SRC_URI="https://ftp.gnu.org/gnu/gzip/gzip-1.14.tar.xz -> gzip-1.14.tar.xz
"

LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="*"
KEYWORDS="*"
IUSE="pic static"

src_prepare() {
	# install symlinks
	sed -i -e 's/ln "$$source" "$$dest" || //' Makefile.in || die
	default
}

src_configure() {
	use static && append-flags -static
	# avoid text relocation in gzip
	use pic && export DEFS="NO_ASM"
	econf --disable-gcc-warnings #663928
}

src_install() {
	default
	docinto txt
	dodoc algorithm.doc gzip.doc

	# keep most things in /usr, just the fun stuff in /
	dodir /bin
	mv "${ED}"/usr/bin/{gunzip,gzip,uncompress,zcat} "${ED}"/bin/ || die
	sed -e "s:${EPREFIX}/usr:${EPREFIX}:" -i "${ED}"/bin/gunzip || die
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Tools for manipulating signed PE-COFF binaries"
HOMEPAGE="https://github.com/rhboot/pesign"
SRC_URI="https://github.com/rhboot/pesign/tarball/ee53c414a2a1a875920ad92cd8634e4927d69e58 -> pesign-116-ee53c41.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:=
	dev-libs/popt
	sys-apps/util-linux
	>=sys-libs/efivar-38
"
DEPEND="${RDEPEND}
	sys-boot/gnu-efi
"
BDEPEND="
	sys-apps/help2man
	virtual/pkgconfig
"

post_src_unpack() {
    if [ ! -d "${S}" ] ; then
        mv ${WORKDIR}/rhboot-* ${S} || die
    fi
}

src_prepare() {
	default
	sed -i -e 's/-Werror//g' "${S}"/Make.defaults || die
}

src_compile() {
	emake \
		AR="$(tc-getAR)" \
		ARFLAGS="-cvqs" \
		AS="$(tc-getAS)" \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		OBJCOPY="$(tc-getOBJCOPY)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		RANLIB="$(tc-getRANLIB)" \
		rundir="${EPREFIX}/var/run"
}

src_install() {
	emake DESTDIR="${ED}" VERSION="${PVR}" rundir="${EPREFIX}/var/run" install
	einstalldocs

	# remove some files that don't make sense for Gentoo installs
	rm -rf "${ED}/etc" "${ED}/var" "${ED}/usr/share/doc/${PF}/COPYING" || die
}
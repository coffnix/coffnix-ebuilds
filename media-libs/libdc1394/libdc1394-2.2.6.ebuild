# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal

DESCRIPTION="Library to interface with IEEE 1394 cameras following the IIDC specification"
HOMEPAGE="https://sourceforge.net/projects/libdc1394/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.gz
	http://ftp.iij.ad.jp/pub/linux/gentoo/distfiles/8b/sdl.m4-20140620.tar.xz"

LICENSE="LGPL-2.1"
SLOT="2/25"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ppc ppc64 ~riscv sparc x86"
IUSE="doc static-libs"

RDEPEND="
	>=sys-libs/libraw1394-2.1.0-r1[${MULTILIB_USEDEP}]
	>=virtual/libusb-1-r1:1[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-text/doxygen )"

PATCHES=( "${FILESDIR}"/${PN}-2.2.1-pthread.patch )

src_prepare() {
	default
	AT_M4DIR=${WORKDIR}/aclocal eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		$(multilib_native_use_enable doc doxygen-html)
		$(use_enable static-libs static)
		--disable-examples
		--program-suffix=2
		--without-x # only useful for (disabled) examples
	)

	multilib_is_native_abi || myeconfargs+=( --disable-doxygen-html )

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	default
	multilib_is_native_abi && use doc && emake doc
}

multilib_src_install() {
	multilib_is_native_abi && use doc && local HTML_DOCS=( doc/html/. )
	default
	find "${ED}" -name '*.la' -delete || die
}

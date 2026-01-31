# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit autotools flag-o-matic

DESCRIPTION="X.Org imake application"
SRC_URI="https://www.x.org/releases/individual/util/imake-1.0.11.tar.xz -> imake-1.0.11.tar.xz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
PATCHES=(
	"${FILESDIR}/imake-1.0.8-cpp-args.patch"
	"${FILESDIR}/imake-1.0.9-no-get-gcc.patch"
	"${FILESDIR}/imake-1.0.8-respect-LD.patch"
)
BDEPEND="virtual/pkgconfig
	
"
RDEPEND="x11-misc/xorg-cf-files
	
"
DEPEND="${RDEPEND}
	sys-devel/autoconf
	sys-devel/automake
	sys-devel/libtool
	sys-devel/m4
	x11-misc/util-macros
	x11-base/xorg-proto
	
	
"

src_prepare() {
	
	eautoreconf || die
	default
}
src_configure() {
	local no_static=""
	local shared=""
	# Check if package supports disabling of static libraries
	if grep -q -s "able-static" ${ECONF_SOURCE:-.}/configure; then
	  no_static="--disable-static"
	fi
	if grep -q -s "enable-shared" ${ECONF_SOURCE:-.}/configure; then
	  shared="--enable-shared"
	fi
	local econfargs=(
	  ${shared}
	  ${no_static}
	  --disable-selective-werror
	 )
	econf "${econfargs[@]}"
}
src_install() {
	default
	find "${D}" -type f -name '*.la' -delete || die
	
}


# vim: filetype=ebuild

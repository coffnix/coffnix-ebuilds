# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit autotools flag-o-matic

DESCRIPTION="analog / digital clock for X"
SRC_URI="https://www.x.org/releases/individual/app/xclock-1.1.1.tar.xz -> xclock-1.1.1.tar.xz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
BDEPEND="virtual/pkgconfig
	
"
RDEPEND="x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXft
	x11-libs/libxkbfile
	x11-libs/libXaw
	
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
	export WANT_AUTOCONF=2.72
	AT_M4DIR="/usr/share/gettext/m4 ." eautoreconf || die
	#eautoreconf || die
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
	  
	)
	econf "${econfargs[@]}"
}
src_install() {
	default
	find "${D}" -type f -name '*.la' -delete || die
	
}


# vim: filetype=ebuild

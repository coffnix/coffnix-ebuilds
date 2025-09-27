# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools

DESCRIPTION="A tool to help manage 'well known' user directories"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/xdg-user-dirs"
SRC_URI="https://user-dirs.freedesktop.org/releases/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="gtk"


RDEPEND=""
# libxslt is mandatory because 0.15 tarball is broken, re:
# https://bugs.freedesktop.org/show_bug.cgi?id=66251
DEPEND="app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	>=sys-devel/gettext-0.26
	sys-devel/gettext"
PDEPEND="gtk? ( x11-misc/xdg-user-dirs-gtk )"

DOCS=( AUTHORS ChangeLog NEWS )
PATCHES=( "${FILESDIR}"/${PN}-0.16-libiconv.patch )

src_prepare() {
	default
	sed -i -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' configure.ac || die

	# autoconf novo e m4 do gettext 0.26
	export WANT_AUTOCONF=2.72
	AT_M4DIR="m4 /usr/share/gettext/m4 ." eautoreconf
}

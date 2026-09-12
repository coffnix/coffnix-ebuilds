# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils

DESCRIPTION="A documentation metadata library"
HOMEPAGE="https://rarian.freedesktop.org/"
SRC_URI="https://gitlab.freedesktop.org/rarian/rarian/-/releases/${PV}/downloads/assets/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND="
	dev-libs/libxslt
	dev-libs/tinyxml
	|| (
		sys-apps/util-linux
		app-misc/getopt )
"
DEPEND="${RDEPEND}
	!<app-text/scrollkeeper-9999
"

DOCS=( ChangeLog NEWS README )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myconf=()
	# https://bugs.gentoo.org/show_bug.cgi?id=409811
	# https://bugs.freedesktop.org/show_bug.cgi?id=53264
	if ! has_version sys-apps/util-linux; then
		myconf=( --with-getopt=getopt-long )
	fi

	econf \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable static-libs static) \
		${myconf[@]}
}

src_install() {
	default
	prune_libtool_files --all
}

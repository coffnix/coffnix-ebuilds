# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils

DESCRIPTION="A replacement for libcrypt with DES, MD5 and blowfish support"
HOMEPAGE="https://github.com/besser82/libxcrypt"
SRC_URI="https://github.com/besser82/libxcrypt/tarball/55ea777e8d567e5e86ffac917c28815ac54cc341 -> libxcrypt-4.4.38-55ea777.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}/besser82-libxcrypt-55ea777"

src_configure() {
    ./autogen.sh

	# Do not install into /usr so that tcb and pam can use us.
	econf --libdir=/$(get_libdir) --disable-static
}

src_install() {
	default
	prune_libtool_files
}

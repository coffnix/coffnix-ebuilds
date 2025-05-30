# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Checks /proc for libraries and files being mapped but marked as deleted"
HOMEPAGE="https://github.com/klausman/lib_users"
SRC_URI="https://github.com/klausman/lib_users/tarball/96ee3c415a3a10e88b22e5e700487bd636e80840 -> lib_users-0.15-96ee3c4.tar.gz
"

DEPEND=""
RDEPEND=""

IUSE=""
RESTRICT="test"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="*"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/klausman-* "$S" || die
	fi
}
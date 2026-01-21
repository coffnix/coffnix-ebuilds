# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Checks /proc for libraries and files being mapped but marked as deleted"
HOMEPAGE="https://codeberg.org/klausman/lib_users"
SRC_URI="https://codeberg.org/klausman/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

DEPEND=""
RDEPEND=""

IUSE=""
RESTRICT="test"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="*"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/lib_users* "$S" || die
	fi
}

my_install() {
	python_newscript lib_users.py lib_users
	python_newscript fd_users.py fd_users
	# lib_users_util/ contains a test script we don't want, so do things by hand
	python_moduleinto lib_users_util
	python_domodule lib_users_util/common.py
	python_domodule lib_users_util/__init__.py
}

src_install() {
	python_foreach_impl my_install
	dodoc README.md TODO
}

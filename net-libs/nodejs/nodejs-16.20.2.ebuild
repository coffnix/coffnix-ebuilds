# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit python-any-r1

DESCRIPTION="Node.js JavaScript runtime"
HOMEPAGE="https://nodejs.org"
SRC_URI="https://api.github.com/repos/nodejs/node/tarball/v16.20.2 -> nodejs-16.20.2.tar.gz"

LICENSE="Apache-1.1 Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="
	${PYTHON_DEPS}
"

post_src_unpack() {
	mv "${WORKDIR}"/nodejs-node-* "${S}" || die
}

src_configure() {
	configure_options=(
		# By default, prefix is /usr/local, which is outside of PATH,
		# set it to /usr instead:
		--prefix="${EPREFIX}"/usr
	)

	# NOTE: `econf` default flags appear to trip up the configure process,
	#       directly call the ./configure script instead.
	./configure "${configure_options[@]}"
}
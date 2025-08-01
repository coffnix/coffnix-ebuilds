# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Fast cryptographic operations for Monero wallets"
HOMEPAGE="https://bench.cr.yp.to/supercop.html"
SRC_URI="https://bench.cr.yp.to/supercop/supercop-20250415.tar.xz"

S="${WORKDIR}/supercop-20250415"

LICENSE="public-domain BSD"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-lang/nasm"
RDEPEND="${DEPEND}"

src_compile() {
	export CC="$(tc-getCC)"
	export CFLAGS="${CFLAGS} -fPIC"
	export TARGET=none

	./do || die "falha ao compilar com ./do"
}

src_install() {
	insinto /usr/include/supercop
	doins -r include/*

	find . -name '*.a' -exec doins -r '{}' + || die "falha ao instalar arquivos estáticos"
}

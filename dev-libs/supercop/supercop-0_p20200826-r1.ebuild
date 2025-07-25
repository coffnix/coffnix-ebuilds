# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Fast cryptographic operations for Monero wallets"
HOMEPAGE="https://bench.cr.yp.to/supercop.html"
SRC_URI="https://bench.cr.yp.to/supercop/supercop-20200826.tar.xz"

S="${WORKDIR}/supercop-20200826"

LICENSE="public-domain BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""

DEPEND="dev-lang/nasm"
RDEPEND="${DEPEND}"

src_compile() {
  CC="$(tc-getCC)" ./do || die "falha ao compilar com ./do"
}

src_install() {
	dodir /usr/share/${PN}
	cp -r . "${D}/usr/share/${PN}" || die "falha ao instalar supercop"
}

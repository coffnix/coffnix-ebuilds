# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="A SSH/SFTP library based on libfilezilla"
HOMEPAGE="https://fzssh.filezilla-project.org/"
SRC_URI="https://dl3.cdn.filezilla-project.org/fzssh/fzssh-1.3.0.tar.xz?h=SPVZjVy1688SO4SM4b-Bnw&x=1782308166 -> ${P}.tar.xz"

LICENSE="AGPL-3+"
SLOT="0/12"
KEYWORDS="*"
IUSE=""

DEPEND="
	>=dev-libs/libfilezilla-0.55.3
	>=dev-libs/gmp-6.2
	>=dev-libs/nettle-3.10
	app-crypt/argon2
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	meson_src_install
	find "${ED}" -type f -name "*.la" -delete || die
}

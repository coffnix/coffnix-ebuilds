# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="A SSH/SFTP library based on libfilezilla"
HOMEPAGE="https://fzssh.filezilla-project.org/"
SRC_URI="https://dl2.cdn.filezilla-project.org/fzssh/${P}.tar.xz?h=4kOuLmVJul5wTYlvxekfuA&x=1779469674 -> ${P}.tar.xz"

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

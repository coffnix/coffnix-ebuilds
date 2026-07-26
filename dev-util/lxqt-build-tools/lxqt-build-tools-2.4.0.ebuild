# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="LXQt Build Tools"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="BSD"
SLOT="0"

DEPEND="
	>=dev-libs/glib-2.50.0
	>=dev-qt/qtbase-6.6:6
"
RDEPEND="${DEPEND}"

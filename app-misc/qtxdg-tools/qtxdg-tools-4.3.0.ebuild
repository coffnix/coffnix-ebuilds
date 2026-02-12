# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="User Tools from libqtxdg"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-2.3.0"
RDEPEND="
	>=dev-libs/libqtxdg-4.3.0
	>=dev-qt/qtbase-6.6:6
"
DEPEND="${RDEPEND}"

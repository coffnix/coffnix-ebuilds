# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="LXQt about dialog"
HOMEPAGE="https://lxqt-project.org/"

MY_PV="$(ver_cut 1-2)"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1+"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-2.3.0"
DEPEND="
	>=dev-libs/libqtxdg-4.3.0
	>=dev-qt/qtbase-6.6:6
	=lxqt-base/liblxqt-${MY_PV}*:=
"
RDEPEND="${DEPEND}"

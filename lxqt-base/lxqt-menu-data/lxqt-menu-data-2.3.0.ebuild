# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV="$(ver_cut 1-2)"

inherit cmake

DESCRIPTION="LXQt Menu Files and Translations for Menu Categories"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="0"

BDEPEND="
	>=dev-qt/qttools-6.6:6[linguist]
	>=dev-util/lxqt-build-tools-2.3.0
"

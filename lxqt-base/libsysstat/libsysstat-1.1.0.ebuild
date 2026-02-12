# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Qt GUI for System Statistics"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-2.1.0"
DEPEND=">=dev-qt/qtbase-6.6:6"
RDEPEND="${DEPEND}"

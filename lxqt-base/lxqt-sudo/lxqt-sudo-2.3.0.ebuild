# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="LXQt GUI frontend for sudo"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1 LGPL-2.1+"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-2.3.0"
DEPEND="
	app-admin/sudo
	>=dev-qt/qtbase-6.6:6[gui,widgets]
	~lxqt-base/liblxqt-${PV}:=
"
RDEPEND="${DEPEND}"

# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="LXQt OpenSSH user password prompt tool"
HOMEPAGE="https://lxqt-project.org/"

MY_PV="$(ver_cut 1-2)"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1 LGPL-2.1+"
SLOT="0"

BDEPEND="
	>=dev-qt/qttools-6.6:6[linguist]
	>=dev-util/lxqt-build-tools-2.3.0
"
DEPEND="
	>=dev-qt/qtbase-6.6:6[widgets]
	=lxqt-base/liblxqt-${MY_PV}*:=
"
RDEPEND="${DEPEND}"

src_install() {
	cmake_src_install
	doman man/*.1

	newenvd - 99${PN} <<- _EOF_
		SSH_ASKPASS='${EPREFIX}/usr/bin/lxqt-openssh-askpass'
	_EOF_
}

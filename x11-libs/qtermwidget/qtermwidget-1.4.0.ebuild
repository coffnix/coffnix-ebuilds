# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Qt terminal emulator widget"
HOMEPAGE="https://lxqt.github.io/"

SRC_URI="https://github.com/lxqt/qtermwidget/releases/download/1.4.0/qtermwidget-1.4.0.tar.xz -> qtermwidget-1.4.0.tar.xz"
KEYWORDS="*"

LICENSE="BSD GPL-2 LGPL-2+"
SLOT="0/${PV}"

BDEPEND="
	dev-qt/linguist-tools:5
	>=dev-util/lxqt-build-tools-0.12.0
"
DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
"
RDEPEND="${DEPEND}"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}

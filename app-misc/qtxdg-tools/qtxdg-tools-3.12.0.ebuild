# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="User Tools from libqtxdg"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/qtxdg-tools/releases/download/3.12.0/qtxdg-tools-3.12.0.tar.xz -> qtxdg-tools-3.12.0.tar.xz"
KEYWORDS="*"

LICENSE="LGPL-2.1"
SLOT="0"

BDEPEND="dev-util/lxqt-build-tools"
RDEPEND="
	dev-libs/libqtxdg
	dev-qt/qtcore:5
"
DEPEND="${RDEPEND}"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv "${WORKDIR}"/* "${S}" || die
	fi
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake xdg

DESCRIPTION="Qt-based multitab terminal emulator"
HOMEPAGE="https://lxqt-project.org/"

SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
KEYWORDS="*"

LICENSE="GPL-2 GPL-2+"
SLOT="0"
IUSE="test wayland"
RESTRICT="!test? ( test )"

BDEPEND=">=dev-util/lxqt-build-tools-2.3.0"
DEPEND="
	>=dev-qt/qtbase-6.6:6=[dbus,gui,widgets,X]
	wayland? ( kde-plasma/layer-shell-qt:6 )
	media-libs/libcanberra
	x11-libs/libX11
	~x11-libs/qtermwidget-${PV}:=
"
RDEPEND="${DEPEND}"

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
	)

	cmake_src_configure
}

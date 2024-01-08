# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake xdg-utils

DESCRIPTION="Qt-based multitab terminal emulator"
KEYWORDS="*"
HOMEPAGE="https://lxqt-project.org/"

LICENSE="GPL-2 GPL-2+"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND=">=dev-util/lxqt-build-tools-0.13.0"
DEPEND="
	>=dev-qt/qtcore-5.15:5
	>=dev-qt/qtdbus-5.15:5
	>=dev-qt/qtgui-5.15:5
	>=dev-qt/qtwidgets-5.15:5
	>=dev-qt/qtx11extras-5.15:5
	x11-libs/libX11
	~x11-libs/qtermwidget-${PV}:=
	test? ( dev-qt/qttest:5 )
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}

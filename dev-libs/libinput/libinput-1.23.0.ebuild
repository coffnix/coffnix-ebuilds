# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )

inherit meson python-any-r1 udev

DESCRIPTION="Library to handle input devices in Wayland"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/libinput/ https://gitlab.freedesktop.org/libinput/libinput"
#SRC_URI="https://www.freedesktop.org/software/${PN}/${P}.tar.xz"
SRC_URI="https://gitlab.freedesktop.org/${PN}/${PN}/-/archive/${PV}/${P}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0/10"
KEYWORDS="*"
IUSE="doc input_devices_wacom"
# Tests require write access to udev rules directory which is a no-no for live system.
# Other tests are just about logs, exported symbols and autotest of the test library.
RESTRICT="test"

BDEPEND="
	virtual/pkgconfig
	doc? (
		$(python_gen_any_dep '
			dev-python/commonmark[${PYTHON_USEDEP}]
			dev-python/recommonmark[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
			>=dev-python/sphinx_rtd_theme-0.2.4[${PYTHON_USEDEP}]
		')
		>=app-doc/doxygen-1.8.3
		>=media-gfx/graphviz-2.38.0
	)
"
#	test? ( dev-util/valgrind )
RDEPEND="
	input_devices_wacom? ( >=dev-libs/libwacom-0.27 )
	>=dev-libs/libevdev-1.9
	>=sys-libs/mtdev-1.1
	virtual/libudev:=
	virtual/udev
"
DEPEND="${RDEPEND}"
#	test? ( >=dev-libs/check-0.9.10 )

python_check_deps() {
	has_version "dev-python/commonmark[${PYTHON_USEDEP}]" && \
	has_version "dev-python/recommonmark[${PYTHON_USEDEP}]" && \
	has_version "dev-python/sphinx[${PYTHON_USEDEP}]" && \
	has_version ">=dev-python/sphinx_rtd_theme-0.2.4[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

src_configure() {
	# gui can be built but will not be installed
	local emesonargs=(
		-Ddebug-gui=false
		$(meson_use doc documentation)
		$(meson_use input_devices_wacom libwacom)
		-Dtests=false # tests are restricted
		-Dudev-dir="$(get_udevdir)"
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	if use doc ; then
		docinto html
		dodoc -r "${BUILD_DIR}"/Documentation/.
	fi
}

pkg_postinst() {
	udevadm hwdb --update --root="${ROOT}"
}

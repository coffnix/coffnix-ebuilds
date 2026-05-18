# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit distutils-r1

DESCRIPTION="QEMU Python support modules"
HOMEPAGE="https://www.qemu.org https://github.com/qemu/qemu"
SRC_URI="https://download.qemu.org/qemu-11.0.0.tar.xz -> qemu-11.0.0.tar.xz"

S=${WORKDIR}/qemu-11.0.0/python

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-python/qemu-qmp[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
"

python_prepare_all() {
	distutils-r1_python_prepare_all
}

python_compile() {
	distutils-r1_python_compile
}

python_test() {
	:
}

python_install_all() {
	distutils-r1_python_install_all
}

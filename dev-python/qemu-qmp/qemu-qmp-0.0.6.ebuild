# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit distutils-r1

DESCRIPTION="QEMU Monitor Protocol (QMP) asyncio Python library"
HOMEPAGE="https://pypi.org/project/qemu.qmp/ https://github.com/qemu/qemu"
SRC_URI="https://files.pythonhosted.org/packages/ea/20/f3fa6bfbcd570a09d5ec65a5398be9251d2bf07398874d2a2c97a05cbdeb/qemu_qmp-${PV}.tar.gz -> qemu_qmp-${PV}.tar.gz"

S=${WORKDIR}/qemu_qmp-${PV}

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
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

# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit distutils-r1

DESCRIPTION="Core VCS versioning functionality from setuptools-scm"
HOMEPAGE="https://github.com/pypa/setuptools-scm/ https://pypi.org/project/vcs-versioning/"
SRC_URI="https://files.pythonhosted.org/packages/source/v/vcs-versioning/vcs_versioning-${PV}.tar.gz -> vcs_versioning-${PV}.tar.gz"

S="${WORKDIR}/vcs_versioning-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-python/packaging-20[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		>=dev-python/setuptools-scm-10[${PYTHON_USEDEP}]
	)
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

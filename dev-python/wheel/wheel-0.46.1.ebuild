# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ pypy3 pypy )
DISTUTILS_USE_PEP517="flit"
inherit distutils-r1

DESCRIPTION="reference implementation of the Python wheel packaging standard, as defined in PEP 427"
HOMEPAGE="None https://pypi.org/project/wheel/"
SRC_URI="https://files.pythonhosted.org/packages/fb/62/e90918c4558b002726ab930863c0cbd3e7cf9a7befa1d4a1a240cecdb379/wheel-0.46.1.tar.gz -> wheel-0.46.1.tar.gz"

DEPEND=""
RDEPEND="python_targets_python2_7? ( dev-python/wheel-compat )"
IUSE="python_targets_python2_7"
SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
S="${WORKDIR}/wheel-0.46.1"
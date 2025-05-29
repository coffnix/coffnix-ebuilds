# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="A Python module to customize the process title"
HOMEPAGE="https://github.com/dvarrazzo/py-setproctitle https://pypi.org/project/setproctitle/"
SRC_URI="https://files.pythonhosted.org/packages/9e/af/56efe21c53ac81ac87e000b15e60b3d8104224b4313b6eacac3597bd183d/setproctitle-1.3.6.tar.gz -> setproctitle-1.3.6.tar.gz"

DEPEND=""
IUSE=""
SLOT="0"
LICENSE="BSD"
KEYWORDS="*"
S="${WORKDIR}/setproctitle-1.3.6"
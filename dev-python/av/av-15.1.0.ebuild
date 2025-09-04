# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="PyAV: bindings Python para FFmpeg"
HOMEPAGE="https://pyav.org/"
SRC_URI="https://files.pythonhosted.org/packages/e9/c3/83e6e73d1592bc54436eae0bc61704ae0cff0c3cfbde7b58af9ed67ebb49/av-15.1.0.tar.gz -> av-15.1.0.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/av-15.1.0"

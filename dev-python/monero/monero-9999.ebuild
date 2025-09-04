# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

PYTHON_COMPAT=( python3+ )
#DISTUTILS_USE_PEP517="standalone"
inherit distutils-r1 git-r3

DESCRIPTION="Monero Python library"
HOMEPAGE="https://github.com/DiosDelRayo/monero-python"
EGIT_REPO_URI="https://github.com/DiosDelRayo/monero-python.git"

SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
#S="${WORKDIR}/RPi.GPIO-0.7.1"

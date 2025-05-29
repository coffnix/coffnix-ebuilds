# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python3+ pypy3 )

inherit distutils-r1

DESCRIPTION="Stemmer algorithms generated from Snowball algorithms"
HOMEPAGE="https://github.com/shibukawa/snowball_py https://pypi.org/project/snowballstemmer/"
SRC_URI="https://files.pythonhosted.org/packages/75/a7/9810d872919697c9d01295633f5d574fb416d47e535f258272ca1f01f447/snowballstemmer-3.0.1.tar.gz -> snowballstemmer-3.0.1.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""
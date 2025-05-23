# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ pypy )
DISTUTILS_USE_PEP517="flit"
inherit distutils-r1

DESCRIPTION="A light, configurable Sphinx theme"
HOMEPAGE="None https://pypi.org/project/alabaster/"
SRC_URI="https://files.pythonhosted.org/packages/c9/3e/13dd8e5ed9094e734ac430b5d0eb4f2bb001708a8b7856cbf8e084e001ba/alabaster-0.7.16.tar.gz -> alabaster-0.7.16.tar.gz"

DEPEND=""
IUSE=""
SLOT="0"
LICENSE="BSD"
KEYWORDS="*"
S="${WORKDIR}/alabaster-0.7.16"
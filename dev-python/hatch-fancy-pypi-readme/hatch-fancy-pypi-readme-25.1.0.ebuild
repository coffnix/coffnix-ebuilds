# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517="hatchling"
inherit distutils-r1

DESCRIPTION="Fancy PyPI READMEs with Hatch"
HOMEPAGE="None https://pypi.org/project/hatch-fancy-pypi-readme/"
SRC_URI="https://files.pythonhosted.org/packages/f3/0f/aed57c301f339936eb91cb4d8c1e5088a101081854bd3ec18a889df32365/hatch_fancy_pypi_readme-25.1.0.tar.gz -> hatch_fancy_pypi_readme-25.1.0.tar.gz"

DEPEND=""
RDEPEND="
	dev-python/tomli[${PYTHON_USEDEP}]
	$(python_gen_cond_dep 'dev-python/typing-extensions[${PYTHON_USEDEP}]' python3_7)"
IUSE=""
SLOT="0"
LICENSE=""
KEYWORDS="*"
S="${WORKDIR}/hatch_fancy_pypi_readme-25.1.0"
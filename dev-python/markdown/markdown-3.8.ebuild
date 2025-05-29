# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ pypy3 )
inherit distutils-r1

DESCRIPTION="Python implementation of the markdown markup language"
HOMEPAGE="https://python-markdown.github.io/
https://pypi.org/project/Markdown/
https://github.com/Python-Markdown/markdown
"
SRC_URI="https://files.pythonhosted.org/packages/2f/15/222b423b0b88689c266d9eac4e61396fe2cc53464459d6a37618ac863b24/markdown-3.8.tar.gz -> markdown-3.8.tar.gz"

DEPEND=""
RDEPEND="$(python_gen_cond_dep 'dev-python/importlib_metadata[${PYTHON_USEDEP}]' -3 pypy3)"
IUSE=""
SLOT="0"
LICENSE="BSD"
KEYWORDS="*"
S="${WORKDIR}/markdown-3.8"

src_prepare() {
	sed -i -e 's/license = "BSD-3-Clause"/license = { text = "BSD-3-Clause" }/' pyproject.toml || die
	sed -i -e '/license-files/d' pyproject.toml || die
	distutils-r1_src_prepare
}

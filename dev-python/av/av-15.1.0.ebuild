# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="PyAV — bindings Python para FFmpeg"
HOMEPAGE="https://pyav.org/ https://github.com/PyAV-Org/PyAV"
SRC_URI="https://files.pythonhosted.org/packages/e9/c3/83e6e73d1592bc54436eae0bc61704ae0cff0c3cfbde7b58af9ed67ebb49/av-15.1.0.tar.gz -> av-15.1.0.tar.gz"

LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/av-15.1.0"

# PyAV 15 precisa de FFmpeg >= 6 por causa de AVChannelLayout e ch_layout
RDEPEND="
	>=media-video/ffmpeg-6.0:0
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"
BDEPEND="
	>=dev-python/cython-3.0[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
"

src_prepare() {
	distutils-r1_src_prepare
	sed -i -e 's/^license *= *.*/license = { text = "BSD-3-Clause" }/' pyproject.toml || die
}


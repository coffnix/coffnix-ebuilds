# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Python bindings for Linux SPI access through spidev"
HOMEPAGE="https://pypi.org/project/spidev/"
SRC_URI="https://files.pythonhosted.org/packages/b5/99/dd50af8200e224ce9412ad01cdbeeb5b39b2d61acd72138f2b92c4a6d619/spidev-3.7.tar.gz -> spidev-3.7.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/spidev-3.7"

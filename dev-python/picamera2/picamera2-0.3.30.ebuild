# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Pure Python interface to the Raspberry Pi camera module"
HOMEPAGE="https://picamera.readthedocs.io/"
SRC_URI="https://files.pythonhosted.org/packages/8d/81/713990c74e3f29a8d0f3f338b611146067745895bb252f0ec9692e10587a/picamera2-0.3.30.tar.gz -> picamera-0.3.30.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/picamera2-0.3.30"

DEPEND="
	media-libs/libcamera[python]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/Pillow[${PYTHON_USEDEP}]
	dev-python/videodev2[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

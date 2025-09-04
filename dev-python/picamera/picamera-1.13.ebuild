# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1

DESCRIPTION="Pure Python interface to the Raspberry Pi camera module"
HOMEPAGE="https://picamera.readthedocs.io/"
SRC_URI="https://files.pythonhosted.org/packages/79/c4/80afe871d82ab1d5c9d8f0c0258228a8a0ed96db07a78ef17e7fba12fda8/picamera-1.13.tar.gz -> picamera-1.13.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/picamera-1.13"

src_prepare() {
    distutils-r1_src_prepare
    # bypass do teste de hardware do setup.py, que dá ValueError fora do Raspberry Pi
    sed -e "s/^ *if not is_raspberry_pi():/if False:/" \
        -e "s/raise ValueError('Unable to determine if this system is a Raspberry Pi')/print('picamera: skipping Raspberry Pi hardware check via ebuild')/" \
        -i setup.py || die
}

# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517="setuptools"
inherit distutils-r1

DESCRIPTION="Extensible Python-based build utility"
HOMEPAGE="https://www.scons.org/"
SRC_URI="https://files.pythonhosted.org/packages/c8/c1/30176c76c1ef723fab62e5cdb15d3c972427a146cb6f868748613d7b25af/scons-4.9.1.tar.gz -> scons-4.9.1.tar.gz"

DEPEND=""
IUSE=""
RESTRICT="test"
SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
S="${WORKDIR}/scons-4.9.1"

if [ "$PN"  == 'scons-compat' ]; then
	S="${WORKDIR}/scons-${PV}"
fi
python_install() {
	distutils-r1_python_install
	rm "${D}"/usr/*.1
	doman *.1

	if [ "$PN"  == 'scons-compat' ]; then
		rm -rf "${D}"/usr/bin
		find "${D}" -type d -name "man" -exec rm -rf \{\} \;
	fi

}

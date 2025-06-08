# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ pypy3 )
inherit distutils-r1

DESCRIPTION="YAML parser and emitter for Python"
HOMEPAGE="https://pyyaml.org/wiki/PyYAML
https://pypi.org/project/PyYAML/
https://github.com/yaml/pyyaml
"
SRC_URI="https://files.pythonhosted.org/packages/54/ed/79a089b6be93607fa5cdaedf301d7dfb23af5f25c398d5ead2525b063e17/pyyaml-6.0.2.tar.gz -> pyyaml-6.0.2.tar.gz"

DEPEND="
	libyaml? ( dev-libs/libyaml )"
RDEPEND="
	libyaml? ( dev-libs/libyaml )"
IUSE="+libyaml examples"
SLOT="0"
LICENSE="MIT"
KEYWORDS="*"
S="${WORKDIR}/pyyaml-6.0.2"

python_configure_all() {
	mydistutilsargs=( $(use_with libyaml) )
}

python_install_all() {
	distutils-r1_python_install_all
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}
	fi
}

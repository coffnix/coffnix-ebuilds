# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit distutils-r1 git-r3

DESCRIPTION="XmrSigner fork do SeedSigner para Monero"
HOMEPAGE="https://github.com/XmrSigner/xmrsigner"
EGIT_REPO_URI="https://github.com/XmrSigner/xmrsigner.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

# muitos testes exigem câmera, GPIO e framebuffer reais
RESTRICT="test"

# docs simples
DOCS=( README.md LICENSE.md )

# dependências em runtime e build iguais
RDEPEND="
	dev-python/monero[${PYTHON_USEDEP}]
	dev-python/polyseed[${PYTHON_USEDEP}]
	dev-python/picamera2[${PYTHON_USEDEP}]
	dev-python/pyzbar[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/spidev[${PYTHON_USEDEP}]
	dev-python/urtypes[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/qrcode[${PYTHON_USEDEP}]
	dev-python/rpi-gpio[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/pynacl[${PYTHON_USEDEP}]
	media-libs/libcamera
"
DEPEND="${RDEPEND}"

src_prepare() {
	# remove o pacote proibido "test" antes de qualquer etapa
	rm -rf test tests || die

	# força o setup a não empacotar "test"
	# casos comuns: find_packages(...) e/ou package_dir {... "test": "test", ...}
	if grep -q "find_packages" setup.py ; then
		sed -i -E \
			's/find_packages\(([^)]*)\)/find_packages(\1, exclude=("test","test.*"))/' \
			setup.py || die
	fi
	sed -i -E '/package_dir *= *\{/{:a;N;/\}/!ba;s/[ ]*"test"[ ]*:[ ]*"test"[ ]*,?[ ]*//}' setup.py || die

	distutils-r1_src_prepare
}

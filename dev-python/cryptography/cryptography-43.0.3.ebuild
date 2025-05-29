# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
DISTUTILS_USE_PEP517="maturin"
CARGO_OPTIONAL="yes"
CRATES="
asn1-0.16.2
asn1_derive-0.16.2
autocfg-1.3.0
base64-0.22.1
bitflags-2.6.0
cc-1.1.6
cfg-if-1.0.0
foreign-types-0.3.2
foreign-types-shared-0.1.1
heck-0.5.0
indoc-2.0.5
libc-0.2.155
memoffset-0.9.1
once_cell-1.19.0
openssl-0.10.68
openssl-macros-0.1.1
openssl-sys-0.9.104
pem-3.0.4
pkg-config-0.3.30
portable-atomic-1.7.0
proc-macro2-1.0.86
pyo3-0.22.2
pyo3-build-config-0.22.2
pyo3-ffi-0.22.2
pyo3-macros-0.22.2
pyo3-macros-backend-0.22.2
quote-1.0.36
self_cell-1.0.4
syn-2.0.71
target-lexicon-0.12.15
unicode-ident-1.0.12
unindent-0.2.3
vcpkg-0.2.15
"

inherit cargo distutils-r1

DESCRIPTION="Library providing cryptographic recipes and primitives"
HOMEPAGE="None https://pypi.org/project/cryptography/"
SRC_URI="https://crates.io/api/v1/crates/asn1/0.16.2/download -> asn1-0.16.2.crate
https://crates.io/api/v1/crates/asn1_derive/0.16.2/download -> asn1_derive-0.16.2.crate
https://crates.io/api/v1/crates/autocfg/1.3.0/download -> autocfg-1.3.0.crate
https://crates.io/api/v1/crates/base64/0.22.1/download -> base64-0.22.1.crate
https://crates.io/api/v1/crates/bitflags/2.6.0/download -> bitflags-2.6.0.crate
https://crates.io/api/v1/crates/cc/1.1.6/download -> cc-1.1.6.crate
https://crates.io/api/v1/crates/cfg-if/1.0.0/download -> cfg-if-1.0.0.crate
https://crates.io/api/v1/crates/foreign-types/0.3.2/download -> foreign-types-0.3.2.crate
https://crates.io/api/v1/crates/foreign-types-shared/0.1.1/download -> foreign-types-shared-0.1.1.crate
https://crates.io/api/v1/crates/heck/0.5.0/download -> heck-0.5.0.crate
https://crates.io/api/v1/crates/indoc/2.0.5/download -> indoc-2.0.5.crate
https://crates.io/api/v1/crates/libc/0.2.155/download -> libc-0.2.155.crate
https://crates.io/api/v1/crates/memoffset/0.9.1/download -> memoffset-0.9.1.crate
https://crates.io/api/v1/crates/once_cell/1.19.0/download -> once_cell-1.19.0.crate
https://crates.io/api/v1/crates/openssl/0.10.68/download -> openssl-0.10.68.crate
https://crates.io/api/v1/crates/openssl-macros/0.1.1/download -> openssl-macros-0.1.1.crate
https://crates.io/api/v1/crates/openssl-sys/0.9.104/download -> openssl-sys-0.9.104.crate
https://crates.io/api/v1/crates/pem/3.0.4/download -> pem-3.0.4.crate
https://crates.io/api/v1/crates/pkg-config/0.3.30/download -> pkg-config-0.3.30.crate
https://crates.io/api/v1/crates/portable-atomic/1.7.0/download -> portable-atomic-1.7.0.crate
https://crates.io/api/v1/crates/proc-macro2/1.0.86/download -> proc-macro2-1.0.86.crate
https://crates.io/api/v1/crates/pyo3/0.22.2/download -> pyo3-0.22.2.crate
https://crates.io/api/v1/crates/pyo3-build-config/0.22.2/download -> pyo3-build-config-0.22.2.crate
https://crates.io/api/v1/crates/pyo3-ffi/0.22.2/download -> pyo3-ffi-0.22.2.crate
https://crates.io/api/v1/crates/pyo3-macros/0.22.2/download -> pyo3-macros-0.22.2.crate
https://crates.io/api/v1/crates/pyo3-macros-backend/0.22.2/download -> pyo3-macros-backend-0.22.2.crate
https://crates.io/api/v1/crates/quote/1.0.36/download -> quote-1.0.36.crate
https://crates.io/api/v1/crates/self_cell/1.0.4/download -> self_cell-1.0.4.crate
https://crates.io/api/v1/crates/syn/2.0.71/download -> syn-2.0.71.crate
https://crates.io/api/v1/crates/target-lexicon/0.12.15/download -> target-lexicon-0.12.15.crate
https://crates.io/api/v1/crates/unicode-ident/1.0.12/download -> unicode-ident-1.0.12.crate
https://crates.io/api/v1/crates/unindent/0.2.3/download -> unindent-0.2.3.crate
https://crates.io/api/v1/crates/vcpkg/0.2.15/download -> vcpkg-0.2.15.crate
https://files.pythonhosted.org/packages/0d/05/07b55d1fa21ac18c3a8c79f764e2514e6f6a9698f1be44994f5adf0d29db/cryptography-43.0.3.tar.gz -> cryptography-43.0.3.tar.gz
$(cargo_crate_uris ${CRATES})"

DEPEND="
	libressl? ( dev-libs/libressl:0= )
	!libressl? ( dev-libs/openssl:0= )
	!x86? ( >=virtual/rust-1.37.0 )
	x86? (
		cpu_flags_x86_sse2? (
			>=virtual/rust-1.37.0
		)
	)
	$(python_gen_cond_dep '>=dev-python/cffi-1.11.3[${PYTHON_USEDEP}] >=dev-python/setuptools-rust-0.12.1[${PYTHON_USEDEP}]' -3)"
RDEPEND="
	>=dev-python/six-1.4.1[${PYTHON_USEDEP}]
	virtual/python-enum34[${PYTHON_USEDEP}]
	virtual/python-ipaddress[${PYTHON_USEDEP}]
	>=dev-python/cffi-1.11.3[${PYTHON_USEDEP}]
	idna? ( >=dev-python/idna-2.1[${PYTHON_USEDEP}] )"
IUSE="cpu_flags_x86_sse2 idna libressl"
SLOT="0"
LICENSE="|| ( Apache-2.0 BSD )"
KEYWORDS="*"
S="${WORKDIR}/cryptography-43.0.3"

pkg_setup() {
	use x86 && ! use cpu_flags_x86_sse2 && export CRYPTOGRAPHY_DONT_BUILD_RUST=1
}
src_unpack() {
	if [[ ${CRYPTOGRAPHY_DONT_BUILD_RUST} ]] || [ "$PN"  == 'cryptography-compat' ] ; then
		default
	else
		cargo_src_unpack
	fi
}

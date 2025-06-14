# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LLVM_COMPAT=( 16 )

inherit cmake llvm

DESCRIPTION="OpenCL-oriented thin wrapper library around clang"
HOMEPAGE="https://github.com/intel/opencl-clang"
SRC_URI="https://github.com/intel/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="UoI-NCSA"
SLOT="$(ver_cut 1)"
KEYWORDS="amd64 ~riscv"

RDEPEND="
	dev-util/spirv-llvm-translator:${SLOT}=
	$(llvm_gen_dep '
		sys-devel/clang:${LLVM_SLOT}=[static-analyzer]
		sys-devel/llvm:${LLVM_SLOT}=
	')
"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-16.0.1-clang_library_dir.patch
)

src_configure() {
	local mycmakeargs=(
		-DCLANG_LIBRARY_DIRS="${EPREFIX}"/usr/lib
		-DCMAKE_INSTALL_PREFIX="$(get_llvm_prefix)"
		-Wno-dev
	)

	cmake_src_configure
}

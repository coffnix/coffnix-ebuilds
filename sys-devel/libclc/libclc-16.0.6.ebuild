# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit cmake llvm llvm.org python-any-r1

DESCRIPTION="OpenCL C library"
HOMEPAGE="https://libclc.llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions || ( MIT BSD )"
SLOT="16"
LLVM_SLOT="16"
KEYWORDS="amd64 arm64 ~riscv x86"
IUSE="+spirv video_cards_nvidia video_cards_r600 video_cards_radeonsi"

LLVM_MAX_SLOT=16
BDEPEND="
	${PYTHON_DEPS}
	|| (
		(
			sys-devel/clang:16
			spirv? ( dev-util/spirv-llvm-translator:16 )
		)
		(
			sys-devel/clang:15
			spirv? ( dev-util/spirv-llvm-translator:15 )
		)
		(
			sys-devel/clang:14
			spirv? ( dev-util/spirv-llvm-translator:14 )
		)
		(
			sys-devel/clang:13
			spirv? ( dev-util/spirv-llvm-translator:13 )
		)
	)
"

LLVM_COMPONENTS=( libclc )
llvm.org_set_globals

llvm_check_deps() {
	if use spirv; then
		has_version -b "dev-util/spirv-llvm-translator:16" ||
			return 1
	fi
	has_version -b "sys-devel/clang:16"
}

pkg_setup() {
	llvm_pkg_setup
	python-any-r1_pkg_setup
}

src_configure() {
	local libclc_targets=()

	use spirv && libclc_targets+=(
		"spirv-mesa3d-"
		"spirv64-mesa3d-"
	)
	use video_cards_nvidia && libclc_targets+=(
		"nvptx--"
		"nvptx64--"
		"nvptx--nvidiacl"
		"nvptx64--nvidiacl"
	)
	use video_cards_r600 && libclc_targets+=(
		"r600--"
	)
	use video_cards_radeonsi && libclc_targets+=(
		"amdgcn--"
		"amdgcn-mesa-mesa3d"
		"amdgcn--amdhsa"
	)
	[[ ${#libclc_targets[@]} ]] || die "libclc target missing!"

	libclc_targets=${libclc_targets[*]}
	local mycmakeargs=(
		-DLIBCLC_TARGETS_TO_BUILD="${libclc_targets// /;}"
	)
	cmake_src_configure
}

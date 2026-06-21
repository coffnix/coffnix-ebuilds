# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
CMAKE_BUILD_TYPE=RelWithDebInfo
inherit cmake flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Compiler runtime library for clang (built-in part)"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.8/llvm-project-20.1.8.src.tar.xz -> llvm-project-20.1.8.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions || ( UoI-NCSA MIT )"
SLOT="20"
KEYWORDS="*"
IUSE="+clang debug"
BDEPEND="dev-util/cmake
	clang? ( sys-devel/clang )
	${PYTHON_DEPS}
	
"
DEPEND="sys-devel/llvm
	
"
S="${WORKDIR}/llvm-src"
post_src_unpack() {
	mv llvm-project-* llvm-src
}
pkg_setup() {
	python-any-r1_pkg_setup
}
src_prepare() {
	CMAKE_USE_DIR="${S}/runtimes"
	#CMAKE_USE_DIR="${S}/compiler-rt"
	local s="${WORKDIR}"
	cmake_src_prepare
}
src_configure() {
	# Ensure to use llvm binary with the right version
	export PATH=${EROOT}/usr/lib/llvm/20/bin:${PATH}
	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	# pre-set since we need to pass it to cmake
	BUILD_DIR=${WORKDIR}/${P}_build
	if use clang; then
			if ! tc-is-clang ; then
			local clang_path="$(command -v clang)"
			local clangxx_path="$(command -v clang++)"
	
			[[ -n "${clang_path}" ]] || die "clang not found in PATH"
			[[ -n "${clangxx_path}" ]] || die "clang++ not found in PATH"
	
			local -x CC="${clang_path}"
			local -x CXX="${clangxx_path}"
			local -x ASM="${clang_path}"
		fi
		strip-unsupported-flags
	fi
	local mycmakeargs=(
	  -DLLVM_CONFIG_PATH="/usr/lib/llvm/20/bin/llvm-config"
	  -DLLVM_ENABLE_RUNTIMES="compiler-rt"
	  -DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/lib/clang/20"
	  -DCOMPILER_RT_INCLUDE_TESTS=OFF
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF
	  -DCOMPILER_RT_BUILD_MEMPROF=OFF
	  -DCOMPILER_RT_BUILD_ORC=OFF
	  -DCOMPILER_RT_BUILD_PROFILE=OFF
	  -DCOMPILER_RT_BUILD_SANITIZERS=OFF
	  -DCOMPILER_RT_BUILD_XRAY=OFF
	  -DPython3_EXECUTABLE="${PYTHON}"
	  -DCAN_TARGET_${CHOST/-pc-*/}=yes
	)
	cmake_src_configure
}


# vim: filetype=ebuild

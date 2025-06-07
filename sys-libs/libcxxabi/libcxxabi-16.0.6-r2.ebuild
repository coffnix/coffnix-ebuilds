# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
CMAKE_BUILD_TYPE=RelWithDebInfo
inherit cmake python-any-r1 toolchain-funcs flag-o-matic

DESCRIPTION="Low level support for a standard C++ library"
HOMEPAGE="https://libcxxabi.llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
SLOT="0"
KEYWORDS="*"
IUSE="+libunwind clang static-libs"

BDEPEND="clang? ( sys-devel/clang:16 )"
RDEPEND="libunwind? (
	  || (
	    sys-libs/libunwind[static-libs?]
	    sys-libs/llvm-libunwind[static-libs?]
	  )
	)"
DEPEND="${RDEPEND}
	sys-devel/llvm:16
"

S="${WORKDIR}/llvm-src/runtimes"

post_src_unpack() {
	mv llvm-project-* llvm-src || die
}

src_configure() {
	local S=${S}/libcxxabi

	# Workaround for Clang + ARM64 toolchain issues
	case "${ARCH}" in
		arm64|aarch64)
			filter-flags -fvect-cost-model=unlimited
			replace-flags -mtune=cortex-a76.cortex-a55 -mtune=cortex-a76
			;;
	esac

	if use clang; then
	  local -x CC=clang
	  local -x CXX=clang++
	fi

	# Link against compiler-rt instead of libgcc if clang + libunwind
	local want_compiler_rt=OFF
	if use libunwind && tc-is-clang; then
	    local compiler_rt=$($(tc-getCC) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -print-libgcc-file-name)
	    if [[ ${compiler_rt} == *libclang_rt* ]]; then
	        want_compiler_rt=ON
	    fi
	fi

	local libdir=$(get_libdir)
	local mycmakeargs=(
	  -DPython3_EXECUTABLE="${PYTHON}"
	  -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx"
	  -DLLVM_ENABLE_EH=ON
	  -DLLVM_ENABLE_RTTI=ON
	  -DLLVM_INCLUDE_TESTS=OFF
	  -DLLVM_LIBDIR_SUFFIX=${libdir#lib}
	  -DLIBCXXABI_LIBDIR_SUFFIX=${libdir#lib}
	  -DLIBCXXABI_ENABLE_SHARED=ON
	  -DLIBCXXABI_USE_LLVM_UNWINDER=$(usex libunwind)
	  -DLIBCXXABI_ENABLE_STATIC=$(usex static-libs)
	  -DLIBCXXABI_INCLUDE_TESTS=OFF
	  -DLIBCXXABI_USE_COMPILER_RT=${want_compiler_rt}
	  -DLIBCXXABI_LIBUNWIND_INCLUDES="${EPREFIX}"/usr/include
	  -DLIBCXXABI_ADDITIONAL_LIBRARIES="-Wl,-lunwind"
	  -DLIBCXX_LIBDIR_SUFFIX=
	  -DLIBCXX_ENABLE_SHARED=ON
	  -DLIBCXX_ENABLE_STATIC=OFF
	  -DLIBCXX_CXX_ABI=libcxxabi
	  -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF
	  -DLIBCXX_HAS_MUSL_LIBC=$(usex elibc_musl)
	  -DLIBCXX_HAS_GCC_S_LIB=OFF
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF
	  -DLIBCXX_INCLUDE_TESTS=OFF
	)

	cmake_src_configure
}

src_compile() {
	cmake_build cxxabi
}

src_install() {
	DESTDIR="${D}" cmake_build install-cxxabi
}

# vim: filetype=ebuild

# Copyright 1999-2025 Funtoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
CMAKE_BUILD_TYPE=RelWithDebInfo
inherit cmake python-any-r1 toolchain-funcs

DESCRIPTION="Low level support for a standard C++ library"
HOMEPAGE="https://libcxxabi.llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
SLOT="0"
KEYWORDS="*"
IUSE="+libunwind clang static-libs"
DEPEND="sys-devel/llvm:16"
BDEPEND="
    dev-util/cmake
    clang? ( sys-devel/clang:16 )
    ${PYTHON_DEPS}
"
RDEPEND="libunwind? (
    || (
        sys-libs/libunwind[static-libs?]
        sys-libs/llvm-libunwind[static-libs?]
    )
)"
S="${WORKDIR}/llvm-src/runtimes"

post_src_unpack() {
    mv llvm-project-* llvm-src || die
}

src_prepare() {
    cmake_src_prepare
}

src_configure() {
    # Ensure to use llvm binary with the right version
    export PATH=${EROOT}/usr/lib/llvm/16/bin:${PATH}

    # LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us
    use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"

    # pre-set since we need to pass it to cmake
    BUILD_DIR=${WORKDIR}/libcxxabi_build

    local extra_cflags=""
    local extra_cppflags=""
    # Force Clang as default compiler
    extra_cflags="-I/usr/lib/clang/16/include/"
    extra_cppflags="-I/usr/lib/clang/16/include/"
    export CPPFLAGS="${extra_cppflags}"
    local -x CC=${CHOST}-clang
    local -x CXX=${CHOST}-clang++
    strip-unsupported-flags

    # Use GCC only if clang USE flag is disabled
    if ! use clang; then
        extra_cflags="-I${BUILD_DIR}/libcxxabi/include/c++/v1"
        extra_cppflags="-I${BUILD_DIR}/libcxxabi/include/c++/v1"
        export CPPFLAGS="${extra_cppflags}"
        local -x CC=${CHOST}-gcc
        local -x CXX=${CHOST}-g++
        strip-unsupported-flags
    fi

    # link against compiler-rt instead of libgcc if we are using clang with libunwind
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
        -DLLVM_ENABLE_RUNTIMES="libcxxabi"
        -DLLVM_ENABLE_EH=ON
        -DLLVM_ENABLE_RTTI=ON
        -DLLVM_INCLUDE_TESTS=OFF
        -DLIBCXXABI_LIBDIR_SUFFIX=${libdir#lib}
        -DLIBCXXABI_ENABLE_SHARED=ON
        -DLIBCXXABI_USE_LLVM_UNWINDER=$(usex libunwind)
        -DLIBCXXABI_ENABLE_STATIC=$(usex static-libs)
        -DLIBCXXABI_INCLUDE_TESTS=OFF
        -DLIBCXXABI_USE_COMPILER_RT=${want_compiler_rt}
        -DLIBCXXABI_LIBUNWIND_INCLUDES="${EPREFIX}/usr/include"
        -DLIBCXXABI_ADDITIONAL_LIBRARIES="-Wl,-lunwind"
        -DLIBCXXABI_ADDITIONAL_COMPILE_FLAGS="${extra_cflags}"
        -DCMAKE_CXX_FLAGS="${CXXFLAGS} ${extra_cflags}"
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

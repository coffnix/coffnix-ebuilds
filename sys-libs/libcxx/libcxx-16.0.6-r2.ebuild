# Copyright 1999-2025 Funtoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit cmake python-any-r1 toolchain-funcs

DESCRIPTION="New implementation of the C++ standard library, targeting C++11"
HOMEPAGE="https://libcxx.llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs clang +libcxxabi +libunwind"
REQUIRED_USE="libunwind? ( libcxxabi )"
DEPEND="
    sys-devel/llvm:16
    libcxxabi? ( ~sys-libs/libcxxabi-${PV}[static-libs?] )
    !libcxxabi? ( sys-devel/gcc[cxx] )
"
BDEPEND="
    dev-util/cmake
    clang? ( sys-devel/clang:16 )
    ${PYTHON_DEPS}
"
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

    # pre-set since we need to pass it to cmake
    BUILD_DIR=${WORKDIR}/libcxx_build

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
        extra_cflags="-I${BUILD_DIR}/libcxx/include/c++/v1"
        extra_cppflags="-I${BUILD_DIR}/libcxx/include/c++/v1"
        export CPPFLAGS="${extra_cppflags}"
        local -x CC=${CHOST}-gcc
        local -x CXX=${CHOST}-g++
        strip-unsupported-flags
    fi

    local cxxabi cxxabi_incs
    if use libcxxabi; then
        cxxabi=system-libcxxabi
        cxxabi_incs="${EPREFIX}/usr/include/c++/v1;${extra_cflags}"
    else
        local gcc_inc="${EPREFIX}/usr/lib/gcc/${CHOST}/$(gcc-fullversion)/include/g++-v$(gcc-major-version)"
        cxxabi=libsupc++
        cxxabi_incs="${gcc_inc};${gcc_inc}/${CHOST};${extra_cflags}"
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
        -DLLVM_ENABLE_RUNTIMES="libcxx"
        -DLLVM_INCLUDE_TESTS=OFF
        -DLIBCXX_USE_LLVM_UNWINDER=$(usex libunwind)
        -DLIBCXX_LIBDIR_SUFFIX=${libdir#lib}
        -DLIBCXX_ENABLE_SHARED=ON
        -DLIBCXX_ENABLE_STATIC=$(usex static-libs)
        -DLIBCXX_CXX_ABI=${cxxabi}
        -DLIBCXX_CXX_ABI_INCLUDE_PATHS=${cxxabi_incs}
        -DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF
        -DLIBCXX_HAS_MUSL_LIBC=$(usex elibc_musl)
        -DLIBCXX_INCLUDE_BENCHMARKS=OFF
        -DLIBCXX_HAS_GCC_S_LIB=OFF
        -DLIBCXX_INCLUDE_TESTS=OFF
        -DLIBCXX_ADDITIONAL_LIBRARIES="-Wl,-lunwind,-lgcc"
        -DLIBCXX_USE_COMPILER_RT=${want_compiler_rt}
        -DCMAKE_CXX_FLAGS="${CXXFLAGS} ${extra_cflags}"
    )

    cmake_src_configure
}

# Usage: deps
gen_ldscript() {
    local output_format
    output_format=$($(tc-getCC) ${CFLAGS} ${LDFLAGS} -Wl,--verbose 2>&1 | sed -n 's/^OUTPUT_FORMAT("\([^"]*\)",.*/\1/p')
    [[ -n ${output_format} ]] && output_format="OUTPUT_FORMAT ( ${output_format} )"
    cat <<-END_LDSCRIPT
/* GNU ld script
   Include missing dependencies
*/
${output_format}
GROUP ( $@ )
END_LDSCRIPT
}

gen_static_ldscript() {
    local libdir=$(get_libdir)
    local cxxabi_lib=$(usex libcxxabi "libc++abi.a" "libsupc++.a")
    # Generate libc++.a ldscript for inclusion of its dependencies so that
    # clang++ -stdlib=libc++ -static works out of the box.
    local deps="libc++_static.a ${cxxabi_lib} $(usex libunwind libunwind.a libgcc_eh.a)"
    # On Linux/glibc it does not link without libpthread or libdl. It is
    # fine on FreeBSD.
    use elibc_glibc && deps+=" libpthread.a libdl.a"
    gen_ldscript "${deps}" > "${ED}/usr/${libdir}/libc++.a" || die
}

gen_shared_ldscript() {
    local libdir=$(get_libdir)
    # libsupc++ doesn't have a shared version
    local cxxabi_lib=$(usex libcxxabi "libc++abi.so" "libsupc++.a")
    mv "${ED}/usr/${libdir}/libc++.so" "${ED}/usr/${libdir}/libc++_shared.so" || die
    local deps="libc++_shared.so ${cxxabi_lib} $(usex libunwind libunwind.so libgcc_s.so)"
    gen_ldscript "${deps}" > "${ED}/usr/${libdir}/libc++.so" || die
}

src_install() {
    local libdir=$(get_libdir)
    cmake_src_install
    mv "${ED}/usr/${libdir}/libc++experimental.a" "${ED}/usr/${libdir}/libc++_static.a" || die
    gen_shared_ldscript
    if use static-libs; then
        gen_static_ldscript
    fi
}

# vim: filetype=ebuild

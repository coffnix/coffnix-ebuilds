# Copyright 1999-2025 Funtoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
CMAKE_BUILD_TYPE=RelWithDebInfo

SANITIZER_FLAGS_ALL=( asan dfsan lsan msan hwasan tsan ubsan safestack cfi scudo shadowcallstack gwp-asan )

case "${ARCH}" in
	arm64|aarch64)
	# Ative apenas os suportados em arm64
	SANITIZER_FLAGS=( asan lsan ubsan scudo )
;;
*)
	SANITIZER_FLAGS=( "${SANITIZER_FLAGS_ALL[@]}" )
;;
esac

inherit cmake flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Compiler runtime libraries for clang (sanitizers & xray)"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions || ( UoI-NCSA MIT )"
SLOT="16"
KEYWORDS="*"

IUSE="clang debug elibc_glibc +libfuzzer +memprof +orc +profile +xray ${SANITIZER_FLAGS_ALL[@]/#/+}"
REQUIRED_USE="|| ( ${SANITIZER_FLAGS_ALL[*]} libfuzzer orc profile xray )"

DEPEND="sys-devel/llvm:16"
BDEPEND="
	dev-util/cmake
	clang? ( sys-devel/clang:16 )
	${PYTHON_DEPS}
"

S="${WORKDIR}/llvm-src"

post_src_unpack() {
	mv llvm-project-* llvm-src || die
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	sed -i -e 's:-Werror::' compiler-rt/lib/tsan/go/buildgo.sh || die

	for flag in "${SANITIZER_FLAGS_ALL[@]}"; do
		if ! use "${flag}"; then
			continue
		fi
		
		case "${ARCH}" in
			arm64|aarch64)
			if [[ "${flag}" =~ ^(cfi|tsan|msan|dfsan|hwasan|shadowcallstack|safestack|gwp-asan)$ ]]; then
				continue
			fi
		;;
		esac
		
		local cmake_flag=${flag/-/_}
		sed -i -e "/COMPILER_RT_HAS_${cmake_flag^^}/s:TRUE:FALSE:" \
		compiler-rt/cmake/config-ix.cmake || die
	done
	
	sed -i -e '/-Wthread-safety/d' compiler-rt/CMakeLists.txt \
	    compiler-rt/cmake/config-ix.cmake || die
	
	if use asan && ! use profile; then
	    rm compiler-rt/test/asan/TestCases/asan_and_llvm_coverage_test.cpp || die
	fi
	if use ubsan && ! use cfi; then
	    > compiler-rt/test/cfi/CMakeLists.txt || die
	fi
	
	if has_version -b ">=sys-libs/glibc-2.37"; then
	    rm compiler-rt/test/dfsan/custom.cpp || die
	    rm compiler-rt/test/dfsan/release_shadow_space.c || die
	fi
	
	CMAKE_USE_DIR="${S}/runtimes"
	cmake_src_prepare
}

src_configure() {
	case "${ARCH}" in
		arm64|aarch64)
		mycmakeargs+=( -DCOMPILER_RT_SANITIZERS_TO_BUILD="asan;ubsan;lsan" )
		;;
	esac
	
	export PATH=${EROOT}/usr/lib/llvm/16/bin:${PATH}
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	BUILD_DIR=${WORKDIR}/compiler-rt_build
	
	local extra_cflags="-I/usr/lib/clang/16/include/ -I${BUILD_DIR}/compiler-rt/lib/fuzzer/libcxx_fuzzer_aarch64/include/c++/v1"
	export CPPFLAGS="${extra_cflags}"
	local -x CC=${CHOST}-clang
	local -x CXX=${CHOST}-clang++
	strip-unsupported-flags
	
	if ! use clang; then
		export CPPFLAGS="${extra_cflags}"
		local -x CC=${CHOST}-gcc
		local -x CXX=${CHOST}-g++
		strip-unsupported-flags
	fi
	
	local flag want_sanitizer=OFF
	for flag in "${SANITIZER_FLAGS[@]}"; do
		if use "${flag}"; then
			want_sanitizer=ON
			break
		fi
	done
	
	local mycmakeargs=(
		-DLLVM_ENABLE_RUNTIMES="compiler-rt"
		-DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/lib/clang/16"
		-DCOMPILER_RT_OUTPUT_DIR="${BUILD_DIR}/lib/clang/16"
		-DCOMPILER_RT_INCLUDE_TESTS=OFF
		-DCOMPILER_RT_BUILD_BUILTINS=OFF
		-DCOMPILER_RT_BUILD_CRT=OFF
		-DCOMPILER_RT_COMMON_CFLAGS="${extra_cflags}"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS} ${extra_cflags}"
		-DCOMPILER_RT_BUILD_LIBFUZZER=$(usex libfuzzer)
		-DCOMPILER_RT_BUILD_MEMPROF=$(usex memprof)
		-DCOMPILER_RT_BUILD_ORC=$(usex orc)
		-DCOMPILER_RT_BUILD_PROFILE=$(usex profile)
		-DCOMPILER_RT_BUILD_SANITIZERS="${want_sanitizer}"
		-DCOMPILER_RT_BUILD_XRAY=$(usex xray)
		-DPython3_EXECUTABLE="${PYTHON}"
		-DCMAKE_SHARED_LINKER_FLAGS="-Wl,-z,defs -Wl,-z,nodelete"
	)

	# Em arm64 desligue XRay e LibFuzzer para evitar headers do libc++ no tree do fuzzer
	case "${ARCH}" in
		arm64|aarch64)
			mycmakeargs+=( -DCOMPILER_RT_BUILD_XRAY=OFF )
			mycmakeargs+=( -DCOMPILER_RT_BUILD_LIBFUZZER=OFF )
		;;
	esac

	cmake_src_configure
}

# vim: filetype=ebuild

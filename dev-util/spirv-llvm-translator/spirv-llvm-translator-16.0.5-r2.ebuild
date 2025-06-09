# Distributed under the terms of the GNU General Public License v2

EAPI=7
CMAKE_BUILD_TYPE=RelWithDebInfo
inherit cmake-utils flag-o-matic

DESCRIPTION="Bi-directional translator between SPIR-V and LLVM IR"
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-LLVM-Translator"
SRC_URI="https://api.github.com/repos/KhronosGroup/SPIRV-LLVM-Translator/tarball/refs/tags/v16.0.5 -> spirv-llvm-translator-16.0.5.tar.gz"
LICENSE="UoI-NCSA"
SLOT="16"
KEYWORDS="*"
IUSE="tools clang"
RDEPEND="sys-devel/clang:16=
	
"
DEPEND="dev-util/spirv-headers
	${RDEPEND}
	clang? (
	  sys-devel/clang:16=
	)
	
"
post_src_unpack() {
	mv KhronosGroup-SPIRV-LLVM-Translator-* ${S}
}
src_prepare() {
	append-flags -fPIC
	cmake-utils_src_prepare
}
src_configure() {
	if use clang; then
	  extra_cflags="-I/usr/lib/clang/16/include/"
	  export CPPFLAGS="-I/usr/lib/clang/16/include/"
	  local -x CC=${CHOST}-clang
	  local -x CXX=${CHOST}-clang++
	  strip-unsupported-flags
	fi
	local mycmakeargs=(
	  -DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/16/"
	  -DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR="${ESYSROOT}/usr/include/spirv"
	  -DBUILD_SHARED_LIBS=True
	  -DLLVM_BUILD_TOOLS=$(usex tools "ON" "OFF")
	)
	cmake-utils_src_configure
}
src_install() {
	cmake-utils_src_install
	# Do not install pkgconfig data files, pkg-config does not presently look at
	# /usr/lib/llvm/.../pkgconfig and putting them in /usr/lib*/pkgconfig would
	# cause collisions between slots.
}


# vim: filetype=ebuild

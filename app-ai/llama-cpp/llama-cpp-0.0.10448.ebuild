# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit cmake

DESCRIPTION="LLM inference in C/C++"
HOMEPAGE="https://llama.app"
SRC_URI="https://api.github.com/repos/ggml-org/llama.cpp/tarball/b10448 -> llama-cpp-0.0.10448-ad1de39.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="static blas cuda vulkan cuda-native"
# Commons depends
CDEPEND="cuda? (
	  dev-util/nvidia-cuda-toolkit
	  dev-util/nvidia-nccl
	)
	vulkan? (
	  dev-util/vulkan-tools
	  media-libs/vulkan-layers
	  media-libs/vulkan-loader
	  media-libs/shaderc
	  sci-libs/gsl
	)
	blas? (
	  virtual/blas
	  virtual/lapack
	)
	
"
BDEPEND="vulkan? (
	  dev-util/vulkan-headers
	)
	
"
RDEPEND="${CDEPEND}
"
DEPEND="${CDEPEND}
"

post_src_unpack() {
	mv ggml-org-llama.cpp-* ${S}
}


src_configure() {
	addpredict /proc/self/task
	if use blas ; then
	  # It seems that -lcblas -lblas is not injected. It's inject only -llapack
	  export LDFLAGS="${LDFLAGS} -lcblas -lblas"
	fi
	export BUILD_COMMIT=ad1de39e0708e3ced9c71bb3c82d93a2c046a73f
	 local mycmakeargs=(
	  -DBUILD_SHARED_LIBS=$(usex static OFF ON)
	  -DGGML_CUDA=$(usex cuda ON OFF)
	  -DGGML_BLAS=$(usex blas ON OFF)
	  -DGGML_VULKAN=$(usex vulkan ON OFF)
	  -DGGML_BLAS_VENDOR=Generic
	  -DGGML_CUDA_ENABLE_UNIFIED_MEMORY=1
	)
	if use cuda-native ; then
	  mycmakeargs+=(
	    -DCMAKE_CUDA_ARCHITECTURES=native
	  )
	else
	  mycmakeargs+=(
	    -DCMAKE_CUDA_ARCHITECTURES='120;100;87;89;75'
	  )
	fi
	cmake_src_configure
}
src_install() {
	cmake_src_install
	dodoc README.md SECURITY.md CONTRIBUTING.md
}



# vim: filetype=ebuild

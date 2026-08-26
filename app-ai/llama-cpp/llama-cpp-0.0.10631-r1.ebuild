# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7

inherit cmake

LLAMA_BUILD="${PV##*.}"
LLAMA_TAG="b${LLAMA_BUILD}"
LLAMA_COMMIT="5d5cb4c3a4ea8769490d39a275ee49a45184774d"
LLAMA_COMMIT_SHORT="${LLAMA_COMMIT:0:7}"
LLAMA_UI="llama-${LLAMA_TAG}-ui.tar.gz"

DESCRIPTION="LLM inference in C/C++"
HOMEPAGE="https://llama.app"

SRC_URI="
	https://api.github.com/repos/ggml-org/llama.cpp/tarball/${LLAMA_TAG} -> ${P}-${LLAMA_COMMIT_SHORT}.tar.gz
	webui? (
		https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_TAG}/${LLAMA_UI}
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

IUSE="static blas cuda vulkan cuda-native webui"

REQUIRED_USE="
	cuda-native? ( cuda )
"

CDEPEND="
	cuda? (
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

BDEPEND="
	vulkan? (
		dev-util/vulkan-headers
	)
"

RDEPEND="${CDEPEND}"
DEPEND="${CDEPEND}"

post_src_unpack() {
	mv ggml-org-llama.cpp-* "${S}" || die
}

src_prepare() {
	cmake_src_prepare

	if use webui ; then
		mkdir -p "${S}/tools/ui/dist" || die

		tar -xzf "${DISTDIR}/${LLAMA_UI}" \
			-C "${S}/tools/ui/dist" \
			--strip-components=1 || die
	fi
}

src_configure() {
	addpredict /proc/self/task

	if use blas ; then
		# It seems that -lcblas -lblas is not injected. It's inject only -llapack
		export LDFLAGS="${LDFLAGS} -lcblas -lblas"
	fi

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex static OFF ON)
		-DGGML_CUDA=$(usex cuda ON OFF)
		-DGGML_BLAS=$(usex blas ON OFF)
		-DGGML_VULKAN=$(usex vulkan ON OFF)
		-DGGML_BLAS_VENDOR=Generic
		-DGGML_CUDA_ENABLE_UNIFIED_MEMORY=1
		-DLLAMA_BUILD_UI=OFF
		-DLLAMA_USE_PREBUILT_UI=OFF
		-DLLAMA_BUILD_NUMBER="${LLAMA_BUILD}"
		-DLLAMA_BUILD_COMMIT="${LLAMA_COMMIT}"
	)

	if use cuda ; then
		if use cuda-native ; then
			local cuda_arch

			command -v nvidia-smi >/dev/null 2>&1 ||
				die "cuda-native requires nvidia-smi"

			cuda_arch="$(
				SANDBOX_ON=0 nvidia-smi \
					--query-gpu=compute_cap \
					--format=csv,noheader 2>/dev/null \
				| grep -E '^[[:space:]]*[0-9]+\.[0-9]+[[:space:]]*$' \
				| tr -d ' .' \
				| sort -u \
				| paste -sd ';' -
			)" || die "Failed to detect CUDA compute capabilities"

			[[ -n ${cuda_arch} ]] ||
				die "Unable to determine CUDA architecture with nvidia-smi"

			einfo "Detected native CUDA architecture(s): ${cuda_arch}"

			mycmakeargs+=(
				-DCMAKE_CUDA_ARCHITECTURES="${cuda_arch}"
			)
		else
			mycmakeargs+=(
				-DCMAKE_CUDA_ARCHITECTURES='120;100;87;89;75'
			)
		fi
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	dodoc README.md SECURITY.md CONTRIBUTING.md

	newinitd "${FILESDIR}/llama-server.initd" llama-server
	newconfd "${FILESDIR}/llama-server.confd" llama-server

	keepdir /var/lib/llama/models
}

# vim: filetype=ebuild

# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LLVM_SLOT=16
inherit cmake llvm

DESCRIPTION="Portable Computing Language (an implementation of OpenCL)"
HOMEPAGE="http://portablecl.org https://github.com/pocl/pocl"
SRC_URI="https://github.com/pocl/pocl/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="accel +conformance cuda debug examples float-conversion hardening +hwloc memmanager test"

RESTRICT="!test? ( test ) test"

RDEPEND="
	sys-devel/clang:${LLVM_SLOT}=
	sys-devel/llvm:${LLVM_SLOT}=
	dev-libs/libltdl
	virtual/opencl
	hwloc? ( sys-apps/hwloc )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	debug? ( dev-util/lttng-ust )
"

DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	use cuda && cuda_src_prepare
	cmake_src_prepare
}

src_configure() {
	local host_cpu_variants="generic"

	if use amd64; then
		host_cpu_variants="distro"
	elif use ppc64; then
		host_cpu_variants="pwr10;pwr9;pwr8;pwr7;pwr6;g5;a2;generic"
	elif use riscv; then
		host_cpu_variants="generic-rv64"
	elif use arm64; then
		host_cpu_variants="cortex-a55"
	fi

	local mycmakeargs=(
		-DENABLE_HSA=OFF
		-DENABLE_ICD=ON
		-DPOCL_ICD_ABSOLUTE_PATH=OFF

		-DENABLE_POCL_BUILDING=ON
		-DKERNELLIB_HOST_CPU_VARIANTS="${host_cpu_variants}"

		-DSTATIC_LLVM=OFF
		-DWITH_LLVM_CONFIG="$(get_llvm_prefix -d)/bin/llvm-config"

		-DENABLE_ALMAIF_DEVICE=$(usex accel)
		-DENABLE_CONFORMANCE=$(usex conformance)
		-DENABLE_CUDA=$(usex cuda)
		-DENABLE_HWLOC=$(usex hwloc)
		-DENABLE_POCL_FLOAT_CONVERSION=$(usex float-conversion)
		-DHARDENING_ENABLE=$(usex hardening)
		-DPOCL_DEBUG_MESSAGES=$(usex debug)
		-DUSE_POCL_MEMMANAGER=$(usex memmanager)
		-DENABLE_EXAMPLES=$(usex examples)
		-DENABLE_TESTS=$(usex test)
	)

	cmake_src_configure
}

src_test() {
	export POCL_BUILDING=1
	export POCL_DEVICES=basic
	export CTEST_OUTPUT_ON_FAILURE=1
	export TEST_VERBOSE=1

	cmake_src_test
}

src_install() {
	cmake_src_install

	# Remove headers que causam colisão com dev-util/opencl-headers
	rm -rf "${ED}/usr/include/CL" || die

	# Documentação dos exemplos se ativado
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}

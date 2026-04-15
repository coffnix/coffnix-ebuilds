# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QA_PREBUILT="/opt/nvidia-cuda-toolkit/*"
inherit unpacker

DESCRIPTION="NVIDIA CUDA Toolkit (compiler and friends)"
SRC_URI="
amd64? ( https://developer.download.nvidia.com/compute/cuda/13.2.1/local_installers/cuda_13.2.1_595.58.03_linux.run -> nvidia-cuda-toolkit-13.2.1_595.58.03_linux_x86_64.run )
arm64? ( https://developer.download.nvidia.com/compute/cuda/13.2.1/local_installers/cuda_13.2.1_595.58.03_linux_sbsa.run -> nvidia-cuda-toolkit-13.2.1_595.58.03_linux_arm64.run )"
LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="*"
IUSE="amd64 arm64 clang examples"
RESTRICT="strip"
BDEPEND="clang? (
	  sys-devel/clang
	)
	sys-process/numactl
	examples? (
	  media-libs/freeglut
	  media-libs/glu
	)
	
"
S="${WORKDIR}"
pkg_setup() {
	if use amd64; then
	  narch=x86_64
	else
	  if use arm64; then
	    narch=sbsa
	  else
	    die "unknown arch ${ARCH}"
	  fi
	fi
	export narch
}
src_configure() {
	:
}
src_compile() {
	:
}
src_install() {
	local target_path=/opt/${PN}
	local dirs=(
	  cuda_cccl
	  cuda_crt
	  cuda_cudart
	  cuda_cuxxfilt
	  cuda_nvcc
	  cuda_nvml_dev
	  cuda_nvrtc
	  cuda_nvtx
	  cuda_opencl
	  cuda_profiler_api
	  cuda_sandbox_dev
	  libcublas
	  libcufft
	  libcufile
	  libcuobjclient
	  libcurand
	  libcusolver
	  libcusparse
	  libnpp
	  libnvfatbin
	  libnvjitlink
	  libnvjpeg
	  libnvptxcompiler
	  libnvvm
	)
	 dodir "${target_path}/lib"
	dodir "${target_path}/include"
	dosym "${target_path}/lib" "${target_path}/lib64"
	 for d in ${dirs[@]}; do
	  insinto "${target_path}/"
	   if [ "${d}" = "libnvvm" ] ; then
	    cd ${WORKDIR}/builds/${d}/
	    doins -r nvvm/
	  else
	    cd ${WORKDIR}/builds/${d}/targets/${narch}-linux/
	    doins -r include/
	    if [ -d ${WORKDIR}/builds/${d}/targets/${narch}-linux/lib/ ] ; then
	      doins -r lib/
	    fi
	    if [ -d ${WORKDIR}/builds/${d}/bin/ ] ; then
	      cd ${WORKDIR}/builds/${d}/
	      doins -r bin/
	    fi
	  fi
	 done
	# Fix exec permissions
	chmod a+x "${D}/${target_path}/bin/*"
	chmod a+x "${D}/${target_path}/nvvm/bin/cicc"
	# Remove broken links
	rm "${D}/${target_path}/lib/lib64"
	rm "${D}/${target_path}/include/include"
	newenvd "${FILESDIR}"/99cuda.envd 99cuda
	dodir ${target_path}/pkgconfig
	insinto ${target_path}/pkgconfig
	cp "${FILESDIR}"/nvidia-cuda-toolkit.pc .
	sed -i -e 's|VERSION|13.2.1|g' nvidia-cuda-toolkit.pc
	doins nvidia-cuda-toolkit.pc
	dodir /etc/revdep-rebuild
	insinto /etc/revdep-rebuild
	newins "${FILESDIR}"/nvidia-cuda-toolkit.revdep 80nvidia-cuda-toolkit
}


# vim: filetype=ebuild

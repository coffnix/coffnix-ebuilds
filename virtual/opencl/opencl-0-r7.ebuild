# Copyright 1999-2018 Gentoo Foundation

EAPI=6

DESCRIPTION="Virtual for OpenCL implementations"
SLOT="0"
KEYWORDS="amd64 x86"
CARDS=( amdgpu i965 nvidia panfrost )
IUSE="${CARDS[@]/#/video_cards_}"

# amdgpu-pro-opencl and intel-ocl-sdk are amd64-only
		#>=media-libs/mesa-9.1.6[opencl]
RDEPEND="
	|| (
		amd64? (
			video_cards_amdgpu? ( dev-libs/amdgpu-pro-opencl )
			dev-util/intel-ocl-sdk
		)
		video_cards_i965? ( dev-libs/beignet )
		video_cards_nvidia? ( >=x11-drivers/nvidia-drivers-290.10-r2[opencl] )
		video_cards_panfrost? ( dev-util/opencl-icd-loader )
	)
	video_cards_panfrost? ( dev-util/opencl-headers )"

pkg_postinst() {
	elog
	elog "In order to take advantage of OpenCL you will need a runtime for your hardware."
	elog "Currently included are:"
	elog
	elog " * open:"
	elog "    - dev-libs/intel-compute-runtime - integrated Intel GPUs from Gen12 onwards. 64-bit only;"
	elog "    - dev-libs/intel-compute-runtime:legacy - integrated Intel GPUs from Gen8 up to Gen11. 64-bit only;"
	elog "    - dev-libs/pocl - to run OpenCL programs on your CPU, if you do not have a supported GPU;"
	elog "    - dev-libs/rocm-opencl-runtime - AMD GPUs supported by the amdgpu kernel driver. 64-bit only;"
	elog "    - media-libs/mesa[opencl] - some older AMD GPUs; see [1]. 32-bit support;"
	elog
	elog " * proprietary:"
	elog "    - dev-libs/amdgpu-pro-opencl - AMD Polaris GPUs. 32-bit support;"
	elog "    - dev-util/intel-ocl-sdk - Intel CPUs (*not* GPUs). 64-bit only;"
	elog "    - x11-drivers/nvidia-drivers - Nvidia GPUs; specific package versions"
	elog "      required for older devices [2]. 32-bit support."
	elog
	elog " [1] https://dri.freedesktop.org/wiki/GalliumCompute/"
	elog " [2] https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/"
	elog
}

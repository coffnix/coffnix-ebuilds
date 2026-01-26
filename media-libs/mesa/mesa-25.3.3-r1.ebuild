# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit meson python-any-r1

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"
SRC_URI="https://archive.mesa3d.org/mesa-25.3.3.tar.xz -> mesa-25.3.3.tar.xz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="cpu_flags_x86_sse2 d3d9 debug +egl +gbm gles1 +gles2 +glvnd +llvm
lm_sensors opencl unwind vaapi valgrind vulkan
vulkan-overlay wayland +X xa zink +zstd llvm_targets_AMDGPU
"
IUSE+="
	video_cards_r300
	video_cards_r600
	video_cards_radeon
	video_cards_radeonsi
	video_cards_freedreno
	video_cards_intel
	video_cards_lima
	video_cards_nouveau
	video_cards_panfrost
	video_cards_v3d
	video_cards_vc4
	video_cards_virgl
	video_cards_vivante
	video_cards_vmware
"
REQUIRED_USE="d3d9?   ( || ( video_cards_intel video_cards_r300 video_cards_r600 video_cards_radeonsi video_cards_nouveau video_cards_vmware ) )
vulkan? ( video_cards_radeonsi? ( llvm ) )
vulkan-overlay? ( vulkan )
video_cards_radeon? ( llvm )
video_cards_r300?   ( llvm )
video_cards_radeonsi?   ( llvm )
xa? ( X )
zink? ( vulkan )
"
BDEPEND="${PYTHON_DEPS}
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	$(python_gen_any_dep "
	  >=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]
	  dev-python/pyyaml[\${PYTHON_USEDEP}]"
	)
	wayland? ( dev-util/wayland-scanner )

"
RDEPEND="dev-libs/expat
	media-libs/libglvnd[X?]
	sys-libs/zlib
	unwind? ( sys-libs/libunwind )
	llvm? (
	  video_cards_radeonsi? (
	    virtual/libelf:0=
	  )
	  video_cards_r600? (
	    virtual/libelf:0=
	  )
	  video_cards_radeon? (
	    virtual/libelf:0=
	  )
	  dev-libs/libclc
	)
	lm_sensors? ( sys-apps/lm_sensors:= )
	opencl? (
	      virtual/opencl
	      dev-libs/libclc
	      virtual/libelf:0=
	    )
	vaapi? (
	  x11-libs/libva:=
	)
	wayland? (
	  dev-libs/wayland:=
	)
	x11-libs/libdrm[video_cards_freedreno?,video_cards_intel?,video_cards_nouveau?,video_cards_vc4?,video_cards_vivante?,video_cards_vmware?]
	vulkan-overlay? ( dev-util/glslang:0= )
	X? (
	  x11-libs/libX11:=
	  x11-libs/libxshmfence:=
	  x11-libs/libXext:=
	  x11-libs/libXxf86vm:=
	  x11-libs/libxcb:=
	  x11-libs/libXfixes:=
	)
	zink? ( media-libs/vulkan-loader:= )
	zstd? ( app-arch/zstd:= )
	vulkan? (
	  dev-util/glslang
	  >=dev-util/spirv-tools-1.4.328.1
	  dev-util/spirv-llvm-translator
	)
	video_cards_r300? (
	  x11-libs/libdrm[video_cards_radeon]
	  sys-devel/llvm[llvm_targets_AMDGPU]
	)
	video_cards_r600? (
	  x11-libs/libdrm[video_cards_radeon]
	  sys-devel/llvm[llvm_targets_AMDGPU]
	)
	video_cards_radeon? (
	  x11-libs/libdrm[video_cards_radeon]
	  sys-devel/llvm[llvm_targets_AMDGPU]
	)
	video_cards_radeonsi? (
	  x11-libs/libdrm[video_cards_radeon]
	  sys-devel/llvm[llvm_targets_AMDGPU]
	)
	video_cards_radeonsi? (
	  x11-libs/libdrm[video_cards_amdgpu]
	  sys-devel/llvm[llvm_targets_AMDGPU]
	)

"
DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )
	wayland? ( dev-libs/wayland-protocols )
	X? (
	  x11-libs/libXrandr
	  x11-base/xorg-proto
	)

"
pkg_setup() {
	python-any-r1_pkg_setup
}
src_configure() {
	local emesonargs=()
	local llvm_version=$(clang --version  | grep version  | cut -d' ' -f 4 | cut -d'.' -f1)
	local platforms
	use X && platforms+="x11"
	use wayland && platforms+=",wayland"
	emesonargs+=(-Dplatforms=${platforms#,})

	if use video_cards_r600 ||
	   use video_cards_radeonsi ||
	   use video_cards_nouveau; then
	  emesonargs+=($(meson_feature vaapi gallium-va))
	  use vaapi && emesonargs+=( -Dva-libs-path="${EPREFIX}"/usr/$(get_libdir)/va/drivers )
	else
	  emesonargs+=(-Dgallium-va=disabled)
	fi

	gallium_enable !llvm softpipe
	gallium_enable llvm llvmpipe
	gallium_enable video_cards_freedreno freedreno
	gallium_enable video_cards_intel crocus i915 iris
	gallium_enable video_cards_lima lima
	gallium_enable video_cards_nouveau nouveau
	gallium_enable video_cards_panfrost panfrost
	gallium_enable video_cards_v3d v3d
	gallium_enable video_cards_vc4 vc4
	gallium_enable video_cards_virgl virgl
	gallium_enable video_cards_vivante etnaviv
	gallium_enable video_cards_vmware svga
	gallium_enable zink zink
	gallium_enable video_cards_r300 r300
	gallium_enable video_cards_r600 r600
	gallium_enable video_cards_radeonsi radeonsi
	if ! use video_cards_r300 && \
	  ! use video_cards_r600; then
	  gallium_enable video_cards_radeon r300 r600
	fi

	if use vulkan; then
	  vulkan_enable video_cards_freedreno freedreno
	  vulkan_enable video_cards_intel intel
	  vulkan_enable video_cards_panfrost panfros
	  vulkan_enable video_cards_radeonsi amd
	  vulkan_enable video_cards_v3d broadcom
	  vulkan_enable video_cards_virgl virtio
	fi

	driver_list() {
	  local drivers="$(sort -u <<< "${1// /$'\n'}")"
	  echo "${drivers//$'\n'/,}"
	}

	local vulkan_layers
	use vulkan && vulkan_layers+="device-select"
	use vulkan-overlay && vulkan_layers+=",overlay"
	emesonargs+=(-Dvulkan-layers=${vulkan_layers#,})

	# Force PKG_CONFIG_PATH for LLVMSPIRVLib
	PKG_CONFIG_PATH="/usr/lib/llvm/${llvm_version}/$(get_libdir)/pkgconfig"

	emesonargs+=(
	  -Dbuild-tests=false
	  -Dexpat=enabled
	  -Dglx=$(usex X dri disabled)
	  $(meson_feature egl)
	  $(meson_feature gbm)
	  $(meson_feature glvnd)
	  $(meson_feature gles1)
	  $(meson_feature gles2)
	  $(meson_feature llvm)
	  $(meson_feature lm_sensors lmsensors)
	  $(meson_feature unwind libunwind)
	  $(meson_feature zstd)
	  $(meson_use cpu_flags_x86_sse2 sse2)
	  -Dvalgrind=$(usex valgrind auto disabled)
	  -Dgallium-drivers=$(driver_list "${GALLIUM_DRIVERS[*]}")
	  -Dvulkan-drivers=$(driver_list "${VULKAN_DRIVERS[*]}")
	  --buildtype $(usex debug debug plain)
	  -Db_ndebug=$(usex debug false true)
	)
	meson_src_configure
}
gallium_enable() {
	if [[ $1 == -- ]] || use $1; then
	  shift
	  GALLIUM_DRIVERS+=("$@")
	fi
}
vulkan_enable() {
	if [[ $1 == -- ]] || use $1; then
	  shift
	  VULKAN_DRIVERS+=("$@")
	fi
}

# vim: filetype=ebuild

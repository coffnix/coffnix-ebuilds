# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LLVM_SLOT=20
LLVM_COMPAT=( 20 )
PYTHON_COMPAT=( python3+ )

inherit llvm-r1 meson python-any-r1

MY_PV="${PV/_/-}"

DESCRIPTION="mesa_clc tool used for building OpenCL C to SPIR-V"
HOMEPAGE="https://mesa3d.org/"

S="${WORKDIR}/mesa-${MY_PV}"
SRC_URI="https://archive.mesa3d.org/mesa-${MY_PV}.tar.xz"
KEYWORDS="*"

LICENSE="MIT"
SLOT="0"

VIDEO_CARDS="asahi panfrost"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done
IUSE="${IUSE_VIDEO_CARDS} debug"

RDEPEND="
	dev-util/spirv-tools
	$(llvm_gen_dep '
		dev-util/spirv-llvm-translator:${LLVM_SLOT}
		sys-devel/clang:${LLVM_SLOT}=
		=dev-libs/libclc-${LLVM_SLOT}*
		sys-devel/llvm:${LLVM_SLOT}=
	')
"
DEPEND="${RDEPEND}
	dev-libs/expat
	>=sys-libs/zlib-1.2.8:=
	x11-libs/libdrm
"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep "
		>=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]
		dev-python/packaging[\${PYTHON_USEDEP}]
		dev-python/pyyaml[\${PYTHON_USEDEP}]
	")
	virtual/pkgconfig
"

python_check_deps() {
	python_has_version -b ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/packaging[${PYTHON_USEDEP}]" &&
	python_has_version -b "dev-python/pyyaml[${PYTHON_USEDEP}]" || return 1
}

pkg_setup() {
	llvm-r1_pkg_setup
	python-any-r1_pkg_setup
}

src_configure() {
	tools_enable video_cards_asahi asahi
	tools_enable video_cards_panfrost panfrost

	tools_list() {
		local tools="$(sort -u <<< "${1// /$'\n'}")"
		echo "${tools//$'\n'/,}"
	}

	PKG_CONFIG_PATH="$(get_llvm_prefix)/$(get_libdir)/pkgconfig"

	use debug && EMESON_BUILDTYPE=debug

	local emesonargs=(
		-Dllvm=enabled
		-Dshared-llvm=enabled
		-Dmesa-clc=enabled
		-Dinstall-mesa-clc=true
		-Dprecomp-compiler=enabled
		-Dinstall-precomp-compiler=true
		-Dtools=$(tools_list "${TOOLS[*]}")

		-Dgallium-drivers=''
		-Dvulkan-drivers=''

		# Set platforms empty to avoid the default "auto" setting. If
		# platforms is empty meson.build will add surfaceless.
		-Dplatforms=''

		-Dglx=disabled
		-Dlibunwind=disabled
		-Dzstd=disabled

		-Db_ndebug=$(usex debug false true)
	)

	meson_src_configure
}

src_install() {
	dobin "${BUILD_DIR}"/src/compiler/clc/mesa_clc
	dobin "${BUILD_DIR}"/src/compiler/spirv/vtn_bindgen2
	use video_cards_asahi && dobin "${BUILD_DIR}"/src/asahi/clc/asahi_clc
	use video_cards_panfrost && dobin "${BUILD_DIR}"/src/panfrost/clc/panfrost_compile
}

# $1 - VIDEO_CARDS flag (check skipped for "--")
# other args - names of tools to enable
tools_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		TOOLS+=("$@")
	fi
}

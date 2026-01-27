# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=SPIRV-Headers
inherit cmake

SRC_URI="https://github.com/KhronosGroup/${MY_PN}/archive/vulkan-sdk-${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~mips ppc ppc64 ~riscv ~s390 ~sparc x86"
S="${WORKDIR}"/${MY_PN}-vulkan-sdk-${PV}

DESCRIPTION="Machine-readable files for the SPIR-V Registry"
HOMEPAGE="https://registry.khronos.org/SPIR-V/ https://github.com/KhronosGroup/SPIRV-Headers"

LICENSE="MIT"
SLOT="0"

src_configure() {
	local mycmakeargs=(
		-DSPIRV_HEADERS_ENABLE_TESTS=OFF
		-DSPIRV_HEADERS_ENABLE_INSTALL=ON
	)
	cmake_src_configure
}

# Distributed under the terms of the MIT License

EAPI=7

inherit cmake git-r3

DESCRIPTION="Fast and highly customizable system information tool"
HOMEPAGE="https://github.com/fastfetch-cli/fastfetch"

EGIT_REPO_URI="https://github.com/fastfetch-cli/fastfetch.git"
EGIT_COMMIT="${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

DEPEND="
	sys-kernel/linux-headers
	app-arch/rpm
	media-libs/libpulse
	app-misc/ddcutil
"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=OFF
	)

	cmake_src_configure
}

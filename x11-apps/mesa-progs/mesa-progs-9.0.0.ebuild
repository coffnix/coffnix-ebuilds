# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

MY_PN="${PN/progs/demos}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Mesa's OpenGL utility and demo programs (glxgears and glxinfo)"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/ https://gitlab.freedesktop.org/mesa/demos"
SRC_URI="https://mesa.freedesktop.org/archive/demos/${MY_P}.tar.xz
	https://mesa.freedesktop.org/archive/demos/${PV}/${MY_P}.tar.xz"
KEYWORDS="*"
S="${WORKDIR}/${MY_P}"

LICENSE="LGPL-2"
SLOT="0"
IUSE="gles2 vulkan wayland X"
REQUIRED_USE="vulkan? ( || ( X wayland ) )"

RDEPEND="
	media-libs/libglvnd[X?]
	vulkan? ( media-libs/vulkan-loader )
	wayland? (
		dev-libs/wayland
		gui-libs/libdecor
		x11-libs/libxkbcommon
	)
	X? (
		x11-libs/libX11
		vulkan? (
			x11-libs/libxcb
			x11-libs/libxkbcommon[X]
		)
	)
"
DEPEND="${RDEPEND}
	wayland? ( >=dev-libs/wayland-protocols-1.12 )
	X? ( xlibre-base/xorg-proto )
"
BDEPEND="
	gui-libs/libdecor
	virtual/pkgconfig
	vulkan? ( dev-util/glslang )
	wayland? ( dev-util/wayland-scanner )
"

PATCHES=(
	"${FILESDIR}"/${PV}-Disable-things-we-don-t-want.patch
	"${FILESDIR}"/${PV}-uint.patch
)

pkg_setup() {
	MULTILIB_CHOST_TOOLS+=(
		/usr/bin/eglinfo
	)

	use X && MULTILIB_CHOST_TOOLS+=(
		/usr/bin/glxgears
		/usr/bin/glxinfo
	)

	use gles2 && use X && MULTILIB_CHOST_TOOLS+=(
		/usr/bin/es2_info
		/usr/bin/es2gears_x11
	)

	use gles2 && use wayland && MULTILIB_CHOST_TOOLS+=(
		/usr/bin/es2gears_wayland
	)

	use vulkan && MULTILIB_CHOST_TOOLS+=(
		/usr/bin/vkgears
	)
}

multilib_src_configure() {
	local emesonargs=(
		-Dlibdrm=disabled
		-Degl=enabled
		-Dgles1=disabled
		$(meson_feature gles2)
		-Dglut=disabled
		-Dosmesa=disabled
		$(meson_feature vulkan)
		$(meson_feature wayland)
		$(meson_feature X x11)
	)
	meson_src_configure
}

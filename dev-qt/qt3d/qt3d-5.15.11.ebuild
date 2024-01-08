# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} != *9999* ]]; then
	KEYWORDS="amd64 ~arm arm64 ~riscv x86"
fi
inherit qt5-build

DESCRIPTION="3D rendering module for the Qt5 framework"

# TODO: tools
IUSE="gamepad gles2-only qml vulkan"

RDEPEND="
	=dev-qt/qtconcurrent-5.15.11*
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtgui-5.15.11*:5=[vulkan=]
	=dev-qt/qtnetwork-5.15.11*
	>=media-libs/assimp-4.0.0:=
	gamepad? ( =dev-qt/qtgamepad-5.15.11* )
	qml? ( =dev-qt/qtdeclarative-5.15.11*[gles2-only=] )
"
DEPEND="${RDEPEND}
	vulkan? ( dev-util/vulkan-headers )
"

src_prepare() {
	rm -r src/3rdparty/assimp/src/{code,contrib,include} || die

	qt_use_disable_mod gamepad gamepad src/input/frontend/frontend.pri
	qt_use_disable_mod qml quick src/src.pro

	qt5-build_src_prepare
}

src_configure() {
	local myqmakeargs=(
		--
		-system-assimp
	)
	qt5-build_src_configure
}

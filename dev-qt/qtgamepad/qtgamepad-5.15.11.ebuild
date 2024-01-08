# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qt5-build

DESCRIPTION="Qt module to support gamepad hardware"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="amd64 ~arm arm64 ~riscv x86"
fi

IUSE="evdev qml sdl"

DEPEND="
	=dev-qt/qtcore-5.15.11*
	=dev-qt/qtgui-5.15.11*[evdev?]
	evdev? ( virtual/libudev:= )
	qml? ( =dev-qt/qtdeclarative-5.15.11* )
	sdl? ( media-libs/libsdl2 )
"
RDEPEND="${DEPEND}"

src_prepare() {
	qt_use_disable_mod qml quick \
		src/src.pro

	qt_use_disable_config evdev evdev \
		src/plugins/gamepads/gamepads.pro

	qt_use_disable_config sdl sdl2 \
		src/plugins/gamepads/gamepads.pro

	qt5-build_src_prepare
}

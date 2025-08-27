# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Qt module to support gamepad hardware"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtgamepad-everywhere-opensource-src-5.15.17.tar.xz -> qtgamepad-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="evdev qml sdl"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5[evdev?]
	evdev? ( virtual/libudev:= )
	qml? ( dev-qt/qtdeclarative:5 )
	sdl? ( media-libs/libsdl2 )
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	qt_use_disable_mod qml quick \
	  src/src.pro
	qt_use_disable_config evdev evdev \
	  src/plugins/gamepads/gamepads.pro
	qt_use_disable_config sdl sdl2 \
	  src/plugins/gamepads/gamepads.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild

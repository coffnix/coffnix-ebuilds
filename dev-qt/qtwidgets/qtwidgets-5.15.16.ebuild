# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qtbase"
inherit qt5-build

DESCRIPTION="Set of components for creating classic desktop-style UIs for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtbase-everywhere-opensource-src-5.15.16.tar.xz -> qtbase-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="dbus gles2-only gtk +png +X"
REQUIRED_USE="gtk? ( dbus )
"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5[gles2-only=,png=,X?]
	dbus? ( dev-qt/qtdbus:5 )
	gtk? (
	  dev-libs/glib:2
	  dev-qt/qtgui:5[dbus]
	  x11-libs/gtk+:3
	  x11-libs/libX11
	  x11-libs/pango
	)
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qtbase-everywhere-src-5.15.16"
QT5_TARGET_SUBDIRS=(
	src/tools/uic
	src/widgets
	src/plugins/platformthemes
)
QT5_GENTOO_CONFIG=(
	dbus:xdgdesktopportal:
	gtk:gtk3:
	::widgets
	!:no-widgets:
)
QT5_GENTOO_PRIVATE_CONFIG=(
	:widgets
)
src_configure() {
	local myconf=(
	  -opengl $(usex gles2-only es2 desktop)
	  $(qt_use dbus)
	  $(qt_use gtk)
	  -gui
	  $(qt_use png libpng system)
	  -widgets
	  $(qt_use X xcb)
	  $(usex X '-xcb-xlib -xkbcommon' '')
	)
	qt5-build_src_configure
}


# vim: filetype=ebuild

# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
QT5_MODULE="qtbase"
inherit qt5-build

DESCRIPTION="OpenGL support library for the Qt5 framework (deprecated)"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.17/submodules/qtbase-everywhere-opensource-src-5.15.17.tar.xz -> qtbase-everywhere-opensource-src-5.15.17.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="gles2-only"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5[gles2-only=]
	dev-qt/qtwidgets:5[gles2-only=]
	
"
DEPEND="${RDEPEND}
"
S="${WORKDIR}/qtbase-everywhere-src-5.15.17"
QT5_TARGET_SUBDIRS=(
	src/opengl
)
src_configure() {
	local myconf=(
	  -opengl $(usex gles2-only es2 desktop)
	)
	qt5-build_src_configure
}


# vim: filetype=ebuild

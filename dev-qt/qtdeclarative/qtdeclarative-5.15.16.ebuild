# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit python-any-r1 qt5-build

DESCRIPTION="The QML and Quick modules for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtdeclarative-everywhere-opensource-src-5.15.16.tar.xz -> qtdeclarative-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="gles2-only +jit localstorage vulkan +widgets"
BDEPEND="${PYTHON_DEPS}
"
RDEPEND="dev-qt/qtcore:5 dev-qt/qtgui:5[gles2-only=,vulkan=] dev-qt/qtnetwork:5 dev-qt/qttest:5 media-libs/libglvnd localstorage? ( dev-qt/qtsql:5 ) widgets? ( dev-qt/qtwidgets:5[gles2-only=] )
"
DEPEND="${RDEPEND}
"
src_prepare() {
	qt_use_disable_mod localstorage sql \
	  src/imports/imports.pro
	qt_use_disable_mod widgets widgets \
	  src/src.pro \
	  src/qmltest/qmltest.pro \
	  tests/auto/auto.pro \
	  tools/tools.pro \
	  tools/qmlscene/qmlscene.pro \
	  tools/qml/qml.pro
	qt5-build_src_prepare
}
src_configure() {
	local myqmakeargs=(
	  --
	  -qml-debug
	  $(qt_use jit feature-qml-jit)
	)
	qt5-build_src_configure
}


# vim: filetype=ebuild

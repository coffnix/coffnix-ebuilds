# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="Application scripting library for the Qt5 framework (deprecated)"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtscript-everywhere-opensource-src-5.15.16.tar.xz -> qtscript-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="+jit scripttools"
RDEPEND="dev-qt/qtcore:5
	scripttools? (
	  dev-qt/qtgui:5
	  dev-qt/qtwidgets:5
	)
	
"
DEPEND="${RDEPEND}
"
src_configure() {
	local myqmakeargs=(
	  JAVASCRIPTCORE_JIT=$(usex jit)
	)
	qt5-build_src_configure
}


# vim: filetype=ebuild

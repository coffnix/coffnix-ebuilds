# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit python-any-r1 qt6-build

DESCRIPTION="A declarative framework for building highly dynamic applications with custom UIs"
HOMEPAGE="https://invent.kde.org/qt/qt/"
SRC_URI="https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtdeclarative-everywhere-src-6.8.3.tar.xz -> qtdeclarative-everywhere-src-6.8.3.tar.xz"
SLOT="6"
KEYWORDS="*"
IUSE="+jit vulkan"
# Commons depends
CDEPEND="dev-qt/qtbase:6[gui,sql,vulkan]
	dev-qt/qtlanguageserver:6
	dev-qt/qtshadertools:6
	dev-qt/qtsvg:6
	
"
BDEPEND="${PYTHON_DEPS}
	
"
RDEPEND="${CDEPEND}
	
"
DEPEND="${CDEPEND}
	vulkan? ( dev-util/vulkan-headers )
	
"
src_configure() {
	local mycmakeargs=(
	  $(qt_feature jit qml_jit)
	)
	qt6-build_src_configure
}


# vim: filetype=ebuild

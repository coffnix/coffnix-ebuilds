# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="XPath, XQuery, XSLT, and XML Schema validation library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtxmlpatterns-everywhere-opensource-src-5.15.16.tar.xz -> qtxmlpatterns-everywhere-opensource-src-5.15.16.tar.xz"
SLOT="5"
KEYWORDS="*"
IUSE="qml"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtnetwork:5
	qml? ( dev-qt/qtdeclarative:5 )
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	qt_use_disable_mod qml qml \
	  src/src.pro \
	  src/imports/imports.pro
	qt_use_disable_mod qml quick tests/auto/auto.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild

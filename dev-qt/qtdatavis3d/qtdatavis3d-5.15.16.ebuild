# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit qt5-build

DESCRIPTION="3D data visualization library for the Qt5 framework"
SRC_URI="https://download.qt.io/archive/qt/5.15/5.15.16/submodules/qtdatavis3d-everywhere-opensource-src-5.15.16.tar.xz -> qtdatavis3d-everywhere-opensource-src-5.15.16.tar.xz"
LICENSE="GPL-3"
SLOT="5"
KEYWORDS="*"
IUSE="gles-only qml vulkan"
RDEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5[vulkan=]
	qml? ( dev-qt/qtdeclarative:5 )
	
"
DEPEND="${RDEPEND}
"
src_prepare() {
	# eliminate bogus dependency on qtwidgets
	sed -i -e '/requires.*widgets/d' qtdatavis3d.pro || die
	qt_use_disable_mod qml quick \
	  src/src.pro
	qt5-build_src_prepare
}


# vim: filetype=ebuild
